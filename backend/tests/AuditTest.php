<?php

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../lib/audit.php';

class AuditTest extends TestCase
{
    public function testEliminaCampoPassword(): void
    {
        $detalle = ['cita_id' => 5, 'password' => 'secreto123'];

        $this->assertSame(['cita_id' => 5], auditLimpiarDetalle($detalle));
    }

    public function testEliminaVariosNombresSensibles(): void
    {
        $detalle = [
            'rol' => 'admin',
            'contrasena' => 'abc',
            'clave_nueva' => 'def',
            'token_sesion' => 'ghi',
            'password_hash' => 'jkl',
        ];

        $this->assertSame(['rol' => 'admin'], auditLimpiarDetalle($detalle));
    }

    public function testIgnoraMayusculasYMinusculas(): void
    {
        $detalle = ['PASSWORD' => 'x', 'Token' => 'y', 'modulo' => 'auth'];

        $this->assertSame(['modulo' => 'auth'], auditLimpiarDetalle($detalle));
    }

    public function testLimpiaTambienArreglosAnidados(): void
    {
        $detalle = [
            'usuario' => ['id' => 3, 'password' => 'x'],
            'ok' => true,
        ];

        $esperado = [
            'usuario' => ['id' => 3],
            'ok' => true,
        ];

        $this->assertSame($esperado, auditLimpiarDetalle($detalle));
    }

    public function testValoresQueNoSonArregloSeDevuelvenIgual(): void
    {
        $this->assertSame('texto', auditLimpiarDetalle('texto'));
        $this->assertSame(7, auditLimpiarDetalle(7));
        $this->assertNull(auditLimpiarDetalle(null));
    }

    public function testArregloVacioSigueVacio(): void
    {
        $this->assertSame([], auditLimpiarDetalle([]));
    }

    public function testConservaLlavesNumericas(): void
    {
        $this->assertSame(['a', 'b'], auditLimpiarDetalle(['a', 'b']));
    }
}