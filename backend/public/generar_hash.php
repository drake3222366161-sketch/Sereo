<?php
$contrasenaEnTextoPlano = 'Sereo2026*';
$hash = password_hash($contrasenaEnTextoPlano, PASSWORD_DEFAULT);
echo $hash;