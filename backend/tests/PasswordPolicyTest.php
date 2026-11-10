<?php

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../lib/password_policy.php';

class PasswordPolicyTest extends TestCase
{
    public function testContrasenaValidaNoTieneFallos(): void
    {
        $this->assertSame([], validarPoliticaContrasena('Clave#Fuerte91'));
    }

    public function testFallaPorLongitud(): void
    {
        $this->assertSame(['longitud'], validarPoliticaContrasena('Ab1#'));
    }

    public function testFallaSinMayuscula(): void
    {
        $this->assertSame(['mayuscula'], validarPoliticaContrasena('clave#fuerte91'));
    }

    public function testFallaSinMinuscula(): void
    {
        $this->assertSame(['minuscula'], validarPoliticaContrasena('CLAVE#FUERTE91'));
    }

    public function testFallaSinNumero(): void
    {
        $this->assertSame(['numero'], validarPoliticaContrasena('Clave#Fuerte'));
    }

    public function testFallaSinCaracterEspecial(): void
    {
        $this->assertSame(['especial'], validarPoliticaContrasena('ClaveFuerte91'));
    }

    public function testFallaSiContieneParteDelCorreo(): void
    {
        $fallos = validarPoliticaContrasena(
            'Maria.lopez#2026',
            'maria.lopez@ucundinamarca.edu.co'
        );
        $this->assertSame(['datos_personales'], $fallos);
    }

    public function testFallaSiContieneElNombreSinTildes(): void
    {
        $fallos = validarPoliticaContrasena('maria#Segura91', '', 'María Gómez');
        $this->assertSame(['datos_personales'], $fallos);
    }

    public function testFallaSiEsContrasenaComun(): void
    {
        $this->assertSame(['comun'], validarPoliticaContrasena('Password123!'));
    }

    public function testCuentaCaracteresNoBytes(): void
    {
        // 10 caracteres, pero más de 10 bytes por la Ñ y la ú
        $this->assertSame([], validarPoliticaContrasena('Ñandú#1234'));
    }
}