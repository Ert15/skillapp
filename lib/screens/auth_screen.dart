import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true, _loading = false;
  bool _showWelcome = true;

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _pass.text;
    final enteredName = _name.text.trim();
    if (email.isEmpty ||
        password.isEmpty ||
        (!_isLogin && enteredName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_isLogin && enteredName.isEmpty
                ? 'Введи имя'
                : 'Введи email и пароль',
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = FirebaseAuth.instance;
      final users = FirebaseFirestore.instance.collection('users');
      if (_isLogin) {
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        final userDoc = users.doc(user.uid);
        final userData = (await userDoc.get()).data();
        final storedName = (userData?['name'] as String?)?.trim();
        final authName = user.displayName?.trim();
        final name =
            authName != null && authName.isNotEmpty && authName != 'Студент'
                ? authName
                : (storedName?.isNotEmpty == true ? storedName : authName);

        if (name != null && name.isNotEmpty) {
          if (user.displayName != name) await user.updateDisplayName(name);
          await userDoc.set(
            {'name': name, 'email': user.email ?? email},
            SetOptions(merge: true),
          );
        }
      } else {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        await user.updateDisplayName(enteredName);
        await users.doc(user.uid).set({
          'name': enteredName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Ошибка Firebase')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _actionButton(String label, VoidCallback onPressed,
      {bool outlined = false}) {
    final style = outlined
        ? OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        : FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
    return outlined
        ? OutlinedButton(onPressed: onPressed, style: style, child: Text(label))
        : FilledButton(onPressed: onPressed, style: style, child: Text(label));
  }

  Widget _welcome() => SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sync_alt,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('SkillSwap',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 28),
                _previewSkillCard('НАВЫК', 'Настрою сервер', 'ХОЧУ',
                    'Помощь с математикой', const Color(0xFFEDEBFF)),
                const SizedBox(height: 10),
                _previewSkillCard('УЧУСЬ', 'Хочу играть на гитаре', 'МОГУ',
                    'Могу помочь с дизайном', const Color(0xFFFFEEE8)),
                const SizedBox(height: 28),
                Text('Меняйтесь навыками,\nа не деньгами',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Расскажите, что умеете или чему хотите научиться',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 24),
                SizedBox(
                    width: double.infinity,
                    child: _actionButton('СОЗДАТЬ АККАУНТ', () {
                      setState(() {
                        _showWelcome = false;
                        _isLogin = false;
                      });
                    })),
                const SizedBox(height: 10),
                SizedBox(
                    width: double.infinity,
                    child: _actionButton('ВОЙТИ', () {
                      setState(() {
                        _showWelcome = false;
                        _isLogin = true;
                      });
                    }, outlined: true)),
              ],
            ),
          ),
        ),
      );

  Widget _previewSkillCard(String firstLabel, String firstValue,
      String secondLabel, String secondValue, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(firstLabel, style: const TextStyle(fontSize: 9)),
        Text(firstValue, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(secondLabel, style: const TextStyle(fontSize: 9)),
        Text(secondValue, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _authForm() => SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => setState(() => _showWelcome = true),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sync_alt, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(_isLogin ? 'Добро пожаловать!' : 'Создайте аккаунт',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                  _isLogin
                      ? 'Войдите, чтобы обмениваться навыками'
                      : 'Создайте аккаунт и начните обмен',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 26),
              if (!_isLogin) ...[
                TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Имя')),
                const SizedBox(height: 12),
              ],
              TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_isLogin ? 'ВОЙТИ' : 'СОЗДАТЬ АККАУНТ'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
                    ? 'Нет аккаунта? Зарегистрироваться'
                    : 'Уже есть аккаунт? Войти'),
              ),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: _showWelcome ? _welcome() : _authForm());
}
