<?php

use PHPUnit\Framework\TestCase;

class PruebaInicialTest extends TestCase
{
    public function testSumaBasica(): void
    {
        $this->assertSame(4, 2 + 2);
    }
}