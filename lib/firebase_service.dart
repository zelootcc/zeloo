import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static User? get usuario => _auth.currentUser;

  static Future<String?> colecaoUsuario() async {
    final uid = usuario?.uid;
    if (uid == null) return null;

    final cliente = await _db.collection('Clientes').doc(uid).get();
    if (cliente.exists) return 'Clientes';

    final profissional = await _db.collection('Profissionais').doc(uid).get();
    if (profissional.exists) return 'Profissionais';

    return null;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> dadosUsuario() async {
    final uid = usuario?.uid;
    final colecao = await colecaoUsuario();

    if (uid == null || colecao == null) return null;

    return _db.collection(colecao).doc(uid).get();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> dadosProfissional() async {
    final uid = usuario?.uid;
    if (uid == null) return null;

    return _db.collection('Profissionais').doc(uid).get();
  }

  static Future<void> atualizarUsuario(Map<String, dynamic> dados) async {
    final uid = usuario?.uid;
    final colecao = await colecaoUsuario();

    if (uid == null) throw Exception('Usuário não autenticado.');
    if (colecao == null) throw Exception('Perfil do usuário não encontrado.');

    await _db.collection(colecao).doc(uid).update(dados);
  }

  static Future<void> atualizarDisponibilidade(bool disponivel) async {
    final uid = usuario?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    await _db.collection('Profissionais').doc(uid).update({
      'disponivel': disponivel,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> profissionais() {
    return _db.collection('Profissionais').snapshots();
  }

  static CollectionReference<Map<String, dynamic>> get _servicos =>
      _db.collection('Servicos');

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusServicos() {
    final uid = usuario?.uid;
    if (uid == null) return const Stream.empty();

    return _servicos
        .where('profissionalId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusServicosDoProfissional(
    String profissionalId,
  ) {
    return _servicos
        .where('profissionalId', isEqualTo: profissionalId)
        .snapshots();
  }

  static Future<void> adicionarServico({
    required String titulo,
    required String descricao,
    required double preco,
    required String categoria,
  }) async {
    final uid = usuario?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    await _servicos.add({
      'profissionalId': uid,
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria,
      'ativo': true,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> atualizarServico(
    String id,
    Map<String, dynamic> dados,
  ) {
    return _servicos.doc(id).update(dados);
  }

  static Future<void> removerServico(String id) {
    return _servicos.doc(id).delete();
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
    final clienteId = usuario?.uid;
    if (clienteId == null) throw Exception('Usuário não autenticado.');

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
    });

    return ref.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusPedidosCliente() {
    final uid = usuario?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('Pedidos')
        .where('clienteId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusPedidosProfissional() {
    final uid = usuario?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('Pedidos')
        .where('profissionalId', isEqualTo: uid)
        .snapshots();
  }

  static Future<void> atualizarStatusPedido(
    String id,
    String status,
  ) {
    return _db.collection('Pedidos').doc(id).update({'status': status});
  }

  static Future<void> sair() {
    return _auth.signOut();
  }
}
