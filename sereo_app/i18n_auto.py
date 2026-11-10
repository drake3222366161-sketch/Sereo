#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
i18n_auto.py - Pasa los textos fijos de la app Flutter a localizacion (es/en).

Uso (desde la RAIZ del proyecto, donde esta pubspec.yaml):
  python i18n_auto.py                     convierte todo lib/*.dart (con copia de seguridad)
  python i18n_auto.py --simular           muestra lo que haria, sin tocar nada
  python i18n_auto.py --en traducido.json mete las traducciones al ingles en app_en.arb
  python i18n_auto.py --contexto          lista lo que quedo sin convertir, con su linea de codigo
  python i18n_auto.py --manual manual.json aplica reemplazos exactos hechos a mano
  python i18n_auto.py --claves claves.json agrega claves nuevas (es + en) al arb
  python i18n_auto.py --revertir          deja los .dart como estaban antes del script
"""
import json
import re
import shutil
import sys
import time
import unicodedata
from pathlib import Path

LIB = Path('lib')
L10N = LIB / 'l10n'
ES = L10N / 'app_es.arb'
EN = L10N / 'app_en.arb'
BACKUP_ROOT = Path('.i18n_backup')
SKIP = {'main.dart', 'locale_controller.dart', 'language_button.dart',
        'theme.dart', 'api_config.dart', 'l10n_ext.dart'}

# Lugares donde un texto literal es casi seguro texto visible para el usuario
PROP_RE = re.compile(
    r'\b(?:Text|SelectableText)\(\s*'
    r'|\b(?:hintText|labelText|helperText|errorText|tooltip|label|title|subtitle|text'
    r'|titulo|subtitulo|etiqueta|texto|descripcion|mensaje|hint)\s*:\s*'
)
IDENT = r'[A-Za-z_]\w*'


# ---------------------------------------------------------------- utilidades
def leer(p):
    return p.read_bytes().decode('utf-8')


def escribir(p, s):
    p.write_bytes(s.encode('utf-8'))


def paquete():
    try:
        for linea in leer(Path('pubspec.yaml')).splitlines():
            m = re.match(r'name:\s*(\w+)', linea)
            if m:
                return m.group(1)
    except OSError:
        pass
    return 'sereo_app'


def cargar_arb(p):
    return json.loads(leer(p)) if p.exists() else {}


def guardar_arb(p, d):
    escribir(p, json.dumps(d, ensure_ascii=False, indent=2) + '\n')


def archivos_dart():
    out = []
    for p in sorted(LIB.rglob('*.dart')):
        if 'l10n' in p.parts or p.name in SKIP or p.name.endswith('.g.dart'):
            continue
        out.append(p)
    return out


# ---------------------------------------------------------------- escaneo
def escanear(src):
    """Devuelve (sin_comentarios, enmascarado). Mismo largo que src.
    enmascarado: ademas el contenido de los strings pasa a 'x'."""
    n = len(src)
    nocom = list(src)
    masked = list(src)
    i = 0
    while i < n:
        if src.startswith('//', i):
            j = src.find('\n', i)
            j = n if j == -1 else j
            for k in range(i, j):
                if src[k] != '\r':
                    nocom[k] = ' '
                    masked[k] = ' '
            i = j
            continue
        if src.startswith('/*', i):
            j = src.find('*/', i + 2)
            j = n if j == -1 else j + 2
            for k in range(i, j):
                if src[k] not in '\r\n':
                    nocom[k] = ' '
                    masked[k] = ' '
            i = j
            continue
        c = src[i]
        if c in '\'"':
            raw = i > 0 and src[i - 1] == 'r'
            q = c * 3 if src.startswith(c * 3, i) else c
            j = i + len(q)
            while j < n:
                if not raw and src[j] == '\\':
                    j += 2
                    continue
                if src.startswith(q, j):
                    break
                j += 1
            for k in range(i + len(q), min(j, n)):
                if src[k] not in '\r\n':
                    masked[k] = 'x'
            i = min(j + len(q), n)
            continue
        i += 1
    return ''.join(nocom), ''.join(masked)


def literal(s, i):
    """Literal simple ('..' o "..") que empieza en s[i]. -> (fin, contenido_crudo) o None."""
    if i >= len(s) or s[i] not in '\'"':
        return None
    if i > 0 and s[i - 1] == 'r' and not s[i - 2:i - 1].isalnum():
        return None  # raw string
    q = s[i]
    if s.startswith(q * 3, i):
        return None  # triple comilla
    j = i + 1
    buf = []
    while j < len(s):
        c = s[j]
        if c == '\\':
            buf.append(s[j:j + 2])
            j += 2
            continue
        if c == q:
            return j + 1, ''.join(buf)
        if c in '\r\n':
            return None
        buf.append(c)
        j += 1
    return None


def secuencia(s, i):
    """Uno o varios literales pegados ('a' 'b') que empiezan en i."""
    primero = literal(s, i)
    if not primero:
        return None
    partes = [primero[1]]
    fin = primero[0]
    while True:
        k = fin
        while k < len(s) and s[k] in ' \t\r\n':
            k += 1
        sig = literal(s, k)
        if sig and k > fin - 1 and s[k] in '\'"':
            partes.append(sig[1])
            fin = sig[0]
        else:
            break
    return i, fin, partes


def decodificar(partes):
    """-> (texto_arb, [(nombre, expresion_dart)]) o None si es demasiado complejo."""
    out = []
    ph = []
    for raw in partes:
        i = 0
        while i < len(raw):
            c = raw[i]
            if c == '\\' and i + 1 < len(raw):
                n = raw[i + 1]
                if n == 'u':
                    m = re.match(r'\\u\{([0-9a-fA-F]+)\}|\\u([0-9a-fA-F]{4})', raw[i:])
                    if m:
                        out.append(chr(int(m.group(1) or m.group(2), 16)))
                        i += len(m.group(0))
                        continue
                out.append({'n': '\n', 't': '\t'}.get(n, n))
                i += 2
                continue
            if c == '$':
                m = re.match(r'\$\{\s*(' + IDENT + r')\s*\}', raw[i:]) or \
                    re.match(r'\$(' + IDENT + ')', raw[i:])
                if m:
                    expr = m.group(1)
                    nombre = expr.lstrip('_') or 'valor'
                    if all(nombre != x[0] for x in ph):
                        ph.append((nombre, expr))
                    out.append('{' + nombre + '}')
                    i += len(m.group(0))
                    continue
                if raw[i:i + 2] == '${':
                    return None
            out.append(c)
            i += 1
    texto = ''.join(out)
    estatico = re.sub(r'\{\w+\}', '', texto)
    if '{' in estatico or '}' in estatico:
        return None
    return texto.replace("'", '\u2019'), ph


def es_tecnico(t):
    if '://' in t or t.startswith('/'):
        return True
    if '@' in t and ' ' not in t:
        return True
    return False


# ---------------------------------------------------------------- const
def consts_envolventes(m, pos):
    """Busca hacia atras los 'const' de los widgets/listas que envuelven pos."""
    spans = []
    depth = 0
    i = pos - 1
    while i >= 0:
        c = m[i]
        if c in ')]}':
            depth += 1
        elif c in '([{':
            if depth > 0:
                depth -= 1
            else:
                antes = m[max(0, i - 200):i]
                if c == '(':
                    mt = re.search(r'\bconst\s+[A-Za-z_][\w\.]*(?:<[^<>]*>)?\s*$', antes)
                else:
                    mt = re.search(r'\bconst\s*(?:<[^<>]*>)?\s*$', antes)
                if mt:
                    ini = i - len(antes) + mt.start()
                    fin = ini + 5
                    while fin < len(m) and m[fin] in ' \t':
                        fin += 1
                    spans.append((ini, fin))
        i -= 1
    return spans


# ---------------------------------------------------------------- claves
def slug(texto):
    t = unicodedata.normalize('NFKD', texto)
    t = ''.join(ch for ch in t if not unicodedata.combining(ch))
    t = re.sub(r'\{\w+\}', ' ', t)
    palabras = re.findall(r'[A-Za-z0-9]+', t)[:4] or ['texto']
    return ''.join(p.capitalize() for p in palabras)


def prefijo_archivo(p):
    partes = p.stem.split('_')
    if len(partes) > 1 and partes[-1] == 'screen':
        partes = partes[:-1]
    return partes[0].lower() + ''.join(x.capitalize() for x in partes[1:])


def obtener_clave(prefijo, texto, ph, es, texto_a_clave, nuevos):
    if texto in texto_a_clave:
        return texto_a_clave[texto]
    base = prefijo + slug(texto)
    clave = base
    n = 1
    while clave in es:
        n += 1
        clave = f'{base}{n}'
    es[clave] = texto
    if ph:
        es['@' + clave] = {'placeholders': {n_: {'type': 'Object'} for n_, _ in ph}}
    texto_a_clave[texto] = clave
    nuevos.append(clave)
    return clave


# ---------------------------------------------------------------- proceso
def procesar(archivo, pkg, es, texto_a_clave, nuevos, manual, simular, carpeta_backup):
    src = leer(archivo)
    nocom, masked = escanear(src)
    ediciones = []
    quitar = set()
    rangos = []
    prefijo = prefijo_archivo(archivo)

    for m in PROP_RE.finditer(nocom):
        r = secuencia(nocom, m.end())
        if not r:
            continue
        ini, fin, partes = r
        k = fin
        while k < len(nocom) and nocom[k] in ' \t\r\n':
            k += 1
        if k >= len(nocom) or nocom[k] not in ',)':
            continue
        linea = src.count('\n', 0, ini) + 1
        dec = decodificar(partes)
        if dec is None:
            manual.append(f'{archivo}:{linea}: (interpolacion compleja) {"".join(partes)[:80]}')
            continue
        texto, ph = dec
        if not re.search(r'[^\W\d_]', re.sub(r'\{\w+\}', '', texto)) or es_tecnico(texto):
            continue
        clave = obtener_clave(prefijo, texto, ph, es, texto_a_clave, nuevos)
        expr = f'context.t.{clave}'
        if ph:
            expr += '(' + ', '.join(e for _, e in ph) + ')'
        ediciones.append((ini, fin, expr))
        rangos.append((ini, fin))
        for a, b in consts_envolventes(masked, ini):
            quitar.add((a, b))

    # pendientes manuales: otros textos que parecen visibles
    for m in re.finditer(r'''(['"])((?:\\.|(?!\1)[^\\\r\n])*)\1''', nocom):
        a, b = m.start(), m.end()
        if any(x <= a < y for x, y in rangos):
            continue
        t = m.group(2)
        ini_linea = nocom.rfind('\n', 0, a) + 1
        linea_txt = nocom[ini_linea:nocom.find('\n', a) if nocom.find('\n', a) != -1 else len(nocom)]
        if re.match(r'\s*(import|export|part)\b', linea_txt):
            continue
        if re.search(r'Uri\.parse|jsonEncode|print\(|debugPrint|RegExp|http|headers|Content-Type', linea_txt):
            continue
        if not re.search(r'[^\W\d_]', t) or len(t) < 4 or es_tecnico(t) or '$' in t:
            continue
        if not (' ' in t or t[0].isupper() or t[0] in '\u00bf\u00a1' or re.search(r'[^\x00-\x7f]', t)):
            continue
        antes = nocom[:a].rstrip()
        sig = nocom[b:].lstrip()
        if antes.endswith('['):
            continue
        if not antes.endswith('?') and sig.startswith(':'):
            continue
        manual.append(f'{archivo}:{src.count(chr(10), 0, a) + 1}: {t[:80]}')

    for mm in re.finditer(r'''DateFormat[^;\n]*['"]es(?:_\w+)?['"]''', nocom):
        manual.append(f'{archivo}:{src.count(chr(10), 0, mm.start()) + 1}: '
                      f'(fecha con idioma fijo "es": usar Localizations.localeOf(context).toString())')

    if not ediciones:
        return 0
    if not simular:
        todas = ediciones + [(a, b, '') for a, b in quitar]
        todas.sort(key=lambda e: e[0], reverse=True)
        nuevo = src
        for a, b, rep in todas:
            nuevo = nuevo[:a] + rep + nuevo[b:]
        imp = f"import 'package:{pkg}/l10n_ext.dart';"
        if imp not in nuevo:
            nl = '\r\n' if '\r\n' in nuevo else '\n'
            ultimos = list(re.finditer(r'^import\s+[^;]+;[ \t]*\r?\n', nuevo, re.M))
            if ultimos:
                pos = ultimos[-1].end()
                nuevo = nuevo[:pos] + imp + nl + nuevo[pos:]
            else:
                nuevo = imp + nl + nuevo
        destino = carpeta_backup / archivo
        destino.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(archivo, destino)
        escribir(archivo, nuevo)
    return len(ediciones)


def modo_convertir(simular):
    if not LIB.exists() or not ES.exists():
        sys.exit('Corre el script desde la raiz del proyecto (donde esta pubspec.yaml) '
                 'y revisa que exista lib/l10n/app_es.arb')
    pkg = paquete()
    es = cargar_arb(ES)
    en = cargar_arb(EN)
    texto_a_clave = {}
    for k, v in es.items():
        if not k.startswith('@') and isinstance(v, str):
            texto_a_clave.setdefault(v, k)
    nuevos, manual = [], []
    carpeta = BACKUP_ROOT / time.strftime('%Y%m%d_%H%M%S')
    total = 0
    for f in archivos_dart():
        n = procesar(f, pkg, es, texto_a_clave, nuevos, manual, simular, carpeta)
        if n:
            print(f'  {f}: {n} textos')
        total += n
    print(f'\nTextos convertidos: {total}  |  claves nuevas: {len(nuevos)}')
    if simular:
        print('(simulacion: no se toco ningun archivo)')
    else:
        for k in nuevos:
            en[k] = es[k]
        guardar_arb(ES, es)
        guardar_arb(EN, en)
        escribir(LIB / 'l10n_ext.dart',
                 "import 'package:flutter/widgets.dart';\n"
                 f"import 'package:{pkg}/l10n/app_localizations.dart';\n\n"
                 "extension L10nContext on BuildContext {\n"
                 "  AppLocalizations get t => AppLocalizations.of(this)!;\n"
                 "}\n")
        pend = {k: v for k, v in es.items()
                if not k.startswith('@') and isinstance(v, str)
                and en.get(k) == v and re.search(r'[^\W\d_]', v)}
        escribir(Path('traducir_a_ingles.json'),
                 json.dumps(pend, ensure_ascii=False, indent=2) + '\n')
        print(f'Para traducir: traducir_a_ingles.json ({len(pend)} textos)')
        if total:
            print(f'Copia de seguridad en: {carpeta}')
    escribir(Path('pendientes_manuales.txt'), '\n'.join(manual) + '\n')
    print(f'Textos que quedaron para revisar a mano: {len(manual)} (pendientes_manuales.txt)')


def modo_en(ruta):
    es = cargar_arb(ES)
    en = cargar_arb(EN)
    datos = json.loads(leer(Path(ruta)))
    ok = 0
    for k, v in datos.items():
        if k not in es:
            print(f'  ignorada (no existe en es): {k}')
            continue
        a = set(re.findall(r'\{(\w+)\}', es[k]))
        b = set(re.findall(r'\{(\w+)\}', v))
        if a != b:
            print(f'  OJO {k}: los {{marcadores}} no coinciden ({sorted(a)} vs {sorted(b)})')
            continue
        en[k] = v
        ok += 1
    guardar_arb(EN, en)
    print(f'Traducciones aplicadas: {ok}')


def modo_revertir():
    if not BACKUP_ROOT.exists():
        sys.exit('No hay copias de seguridad.')
    ultima = sorted(BACKUP_ROOT.iterdir())[-1]
    n = 0
    for f in ultima.rglob('*.dart'):
        destino = f.relative_to(ultima)
        shutil.copy2(f, destino)
        n += 1
    print(f'Restaurados {n} archivos desde {ultima}')


LIT_RE = re.compile(r"""(['"])((?:\\.|(?!\1)[^\\\r\n])*)\1""")


def prefijo_pkg_y_arbs():
    pkg = paquete()
    es = cargar_arb(ES)
    en = cargar_arb(EN)
    t2k = {}
    for k, v in es.items():
        if not k.startswith('@') and isinstance(v, str):
            t2k.setdefault(v, k)
    return pkg, es, en, t2k


def modo_contexto():
    """Lista lo que quedo sin convertir, con la linea de codigo al lado."""
    pkg, es, en, t2k = prefijo_pkg_y_arbs()
    manual = []
    for f in archivos_dart():
        procesar(f, pkg, dict(es), dict(t2k), [], manual, True, None)
    salida, cache = [], {}
    omitidos = 0
    for item in manual:
        m = re.match(r'(.+?):(\d+): (.*)', item)
        if not m:
            continue
        f, n, txt = m.group(1), int(m.group(2)), m.group(3)
        if f.replace('\\', '/').endswith('politica_screen.dart'):
            omitidos += 1
            continue
        lineas = cache.setdefault(f, leer(Path(f)).splitlines())
        codigo = lineas[n - 1].strip()[:150] if 0 < n <= len(lineas) else ''
        salida.append(f'{f}:{n}: {txt}  ||  {codigo}')
    escribir(Path('contexto_pendientes.txt'), '\n'.join(salida) + '\n')
    print(f'contexto_pendientes.txt: {len(salida)} lineas '
          f'({omitidos} de politica_screen.dart omitidas, se hacen aparte)')


def aplicar_ediciones(archivo, src, ediciones, quitar, pkg, carpeta_backup):
    todas = ediciones + [(a, b, '') for a, b in quitar]
    todas.sort(key=lambda e: e[0], reverse=True)
    nuevo = src
    for a, b, rep in todas:
        nuevo = nuevo[:a] + rep + nuevo[b:]
    imp = f"import 'package:{pkg}/l10n_ext.dart';"
    if imp not in nuevo:
        nl = '\r\n' if '\r\n' in nuevo else '\n'
        ultimos = list(re.finditer(r'^import\s+[^;]+;[ \t]*\r?\n', nuevo, re.M))
        if ultimos:
            pos = ultimos[-1].end()
            nuevo = nuevo[:pos] + imp + nl + nuevo[pos:]
        else:
            nuevo = imp + nl + nuevo
    destino = carpeta_backup / archivo
    destino.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(archivo, destino)
    escribir(archivo, nuevo)


def modo_manual(ruta):
    """Aplica una lista de reemplazos exactos (manual.json)."""
    pkg, es, en, t2k = prefijo_pkg_y_arbs()
    entradas = json.loads(leer(Path(ruta)))
    por_archivo = {}
    for e in entradas:
        por_archivo.setdefault(e['archivo'], []).append(e)
    carpeta = BACKUP_ROOT / time.strftime('%Y%m%d_%H%M%S')
    total = 0
    for arch, lista in por_archivo.items():
        f = Path(arch)
        if not f.exists():
            print(f'  no existe: {arch}')
            continue
        src = leer(f)
        nocom, masked = escanear(src)
        lits = [(m.start(), m.end(), m.group(2)) for m in LIT_RE.finditer(nocom)]
        ediciones, quitar = [], set()
        for e in lista:
            cands = [(a, b) for a, b, t in lits if t == e['texto']
                     and (e.get('linea') is None or src.count('\n', 0, a) + 1 == e['linea'])]
            if e.get('ocurrencia') is not None:
                cands = cands[e['ocurrencia']:e['ocurrencia'] + 1]
            if not cands:
                print(f'  NO ENCONTRADO en {arch}: {e["texto"][:60]}')
                continue
            if e.get('es'):
                es_txt = e['es']
                nombres = list(dict.fromkeys(re.findall(r'\{(\w+)\}', es_txt)))
            else:
                dec = decodificar([e['texto']])
                if dec is None:
                    print(f'  muy complejo: {e["texto"][:60]}')
                    continue
                es_txt, ph = dec
                nombres = [n for n, _ in ph]
                if not e.get('args'):
                    e['args'] = [x for _, x in ph]
            args = e.get('args', [])
            if len(args) != len(nombres):
                print(f'  OJO: {e["texto"][:50]} necesita {len(nombres)} argumentos')
                continue
            if es_txt in t2k:
                clave = t2k[es_txt]
            else:
                clave = e['clave']
                if clave in es:
                    print(f'  OJO: la clave {clave} ya existe con otro texto')
                    continue
                es[clave] = es_txt
                if nombres:
                    es['@' + clave] = {'placeholders': {n: {'type': 'Object'} for n in nombres}}
                en[clave] = e.get('en', es_txt)
                t2k[es_txt] = clave
            expr = f'context.t.{clave}' + (f'({", ".join(args)})' if args else '')
            for a, b in cands:
                ediciones.append((a, b, expr))
                for x, y in consts_envolventes(masked, a):
                    quitar.add((x, y))
        if ediciones:
            aplicar_ediciones(f, src, ediciones, quitar, pkg, carpeta)
            print(f'  {arch}: {len(ediciones)} reemplazos')
            total += len(ediciones)
    guardar_arb(ES, es)
    guardar_arb(EN, en)
    escribir(LIB / 'l10n_ext.dart',
             "import 'package:flutter/widgets.dart';\n"
             f"import 'package:{pkg}/l10n/app_localizations.dart';\n\n"
             "extension L10nContext on BuildContext {\n"
             "  AppLocalizations get t => AppLocalizations.of(this)!;\n"
             "}\n")
    print(f'Total reemplazos manuales: {total}')



def modo_claves(ruta):
    """Agrega claves nuevas (es + en) desde un JSON: {"clave": {"es": "...", "en": "..."}}"""
    es = cargar_arb(ES)
    en = cargar_arb(EN)
    datos = json.loads(leer(Path(ruta)))
    n = 0
    for k, v in datos.items():
        if k in es:
            print(f'  ya existe, se omite: {k}')
            continue
        a = list(dict.fromkeys(re.findall(r'\{(\w+)\}', v['es'])))
        b = list(dict.fromkeys(re.findall(r'\{(\w+)\}', v['en'])))
        if set(a) != set(b):
            print(f'  OJO {k}: los {{marcadores}} no coinciden')
            continue
        es[k] = v['es']
        en[k] = v['en']
        if a:
            es['@' + k] = {'placeholders': {x: {'type': 'Object'} for x in a}}
        n += 1
    guardar_arb(ES, es)
    guardar_arb(EN, en)
    print(f'Claves agregadas: {n}')



if __name__ == '__main__':
    args = sys.argv[1:]
    if '--revertir' in args:
        modo_revertir()
    elif '--claves' in args:
        modo_claves(args[args.index('--claves') + 1])
    elif '--contexto' in args:
        modo_contexto()
    elif '--manual' in args:
        modo_manual(args[args.index('--manual') + 1])
    elif '--en' in args:
        modo_en(args[args.index('--en') + 1])
    else:
        modo_convertir('--simular' in args)
