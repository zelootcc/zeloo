import 'package:flutter/material.dart';

import 'notificacoes_screen.dart';
import 'notificacoes_service.dart';

class BotaoNotificacoes extends StatelessWidget {
  const BotaoNotificacoes({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: NotificacoesService.minhas(),
    builder: (context, snapshot) {
      final novas =
          snapshot.data?.docs
              .where((doc) => doc.data()['lida'] != true)
              .length ??
          0;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
              ),
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          if (novas > 0)
            Positioned(
              right: -5,
              top: -7,
              child: Container(
                constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5C5C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  novas > 99 ? '99+' : '$novas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
