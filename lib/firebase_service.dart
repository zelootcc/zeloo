import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get usuario => _auth.currentUser;

  static String get uid {
    final id = usuario?.uid;
    if (id == null) {
      throw Exception('Usuário não autenticado.');
    }
    return id;
  }

  static Future<String?> colecaoUsuario() async {
    final id = usuario?.uid;
    if (id == null) return null;

    final cliente = await _db.collection('Clientes').doc(id).get();
    if (cliente.exists) return 'Clientes';

    final profissional = await _db.collection('Profissionais').doc(id).get();
    if (profissional.exists) return 'Profissionais';

    return null;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> dadosUsuario() async {
    final id = usuario?.uid;
    final colecao = await colecaoUsuario();

    if (id == null || colecao == null) return null;

    return _db.collection(colecao).doc(id).get();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> dadosProfissional() async {
    final id = usuario?.uid;
    if (id == null) return null;

    return _db.collection('Profissionais').doc(id).get();
  }

  static Future<void> atualizarUsuario(Map<String, dynamic> dados) async {
    final colecao = await colecaoUsuario();

    if (colecao == null) {
      throw Exception('Perfil do usuário não encontrado.');
    }

    await _db.collection(colecao).doc(uid).update(dados);
  }

  static Future<void> atualizarDisponibilidade(bool disponivel) async {
    await _db.collection('Profissionais').doc(uid).update({
      'disponivel': disponivel,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> profissionais() {
    return _db.collection('Profissionais').snapshots();
  }

  static CollectionReference<Map<String, dynamic>> get _servicos {
    return _db.collection('Servicos');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusServicos() {
    return _servicos
        .where('profissionalId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusServicosDoProfissional(
    String profissionalId,
  ) {
    return _servicos
        .where('profissionalId', isEqualTo: profissionalId)
        .where('ativo', isEqualTo: true)
        .snapshots();
  }

  static Future<void> adicionarServico({
    required String titulo,
    required String descricao,
    required double preco,
    required String categoria,
  }) async {
    await _servicos.add({
      'profissionalId': uid,
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria,
      'ativo': true,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> atualizarServico(
    String id,
    Map<String, dynamic> dados,
  ) async {
    final dadosAtualizados = Map<String, dynamic>.from(dados);
    dadosAtualizados['atualizadoEm'] = FieldValue.serverTimestamp();

    await _servicos.doc(id).update(dadosAtualizados);
  }

  static Future<void> removerServico(String id) async {
    await _servicos.doc(id).delete();
  }

  static Future<String> criarPedido({
    required String profissionalId,
    required String profissionalNome,
    required String servicoId,
    required String servico,
    required double valor,
    required String data,
    required String horario,
    String descricao = '',
  }) async {
    final clienteId = uid;

    final profissional = await _db
        .collection('Profissionais')
        .doc(profissionalId)
        .get();

    if (!profissional.exists) {
      throw Exception('Profissional não encontrado.');
    }

    final servicoDoc = await _servicos.doc(servicoId).get();

    if (!servicoDoc.exists) {
      throw Exception('Serviço não encontrado.');
    }

    final dadosServico = servicoDoc.data()!;

    if (dadosServico['profissionalId'] != profissionalId) {
      throw Exception('Serviço inválido para este profissional.');
    }

    if (dadosServico['ativo'] != true) {
      throw Exception('Este serviço não está disponível.');
    }

    final ref = await _db.collection('Pedidos').add({
      'clienteId': clienteId,
      'profissionalId': profissionalId,
      'profissionalNome': profissionalNome,
      'servicoId': servicoId,
      'servico': servico,
      'valor': valor,
      'data': data,
      'horario': horario,
      'descricao': descricao,
      'status': 'aguardando',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusPedidosCliente() {
    return _db
        .collection('Pedidos')
        .where('clienteId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusPedidosProfissional() {
    return _db
        .collection('Pedidos')
        .where('profissionalId', isEqualTo: uid)
        .snapshots();
  }

  static Future<void> atualizarStatusPedido(
    String id,
    String status,
  ) async {
    const statusValidos = {
      'aguardando',
      'confirmado',
      'cancelado',
      'concluido',
    };

    if (!statusValidos.contains(status)) {
      throw Exception('Status de pedido inválido.');
    }

    await _db.collection('Pedidos').doc(id).update({
      'status': status,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sair() {
    return _auth.signOut();
  }
}
