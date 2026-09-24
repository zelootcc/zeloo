import 'package:flutter/material.dart';
import 'perfil_lista_privada.dart';

class PerfilPagamentosScreen extends StatelessWidget {
  const PerfilPagamentosScreen({super.key});
  @override
  Widget build(BuildContext context) => const PerfilListaPrivada(cartoes: true);
}
