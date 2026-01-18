import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  // Cores do Figma
  static const Color _primaryGreen = Color.fromARGB(255, 128, 188, 77); // Verde padrão
  static const Color _textGrey = Color(0xFF424242); // Cinza Escuro
  static const Color _borderGrey = Color(0xFFE0E0E0); // Cinza Claro
  static const Color _iconGrey = Color(0xFF9E9E9E); // Cinza Médio

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listener para redirecionar após Logout
    ref.listen(settingsViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Ao completar logout, vai para Login e limpa pilha
          context.go(AppRoutes.login);
        },
        error: (err, stack) {
          // Em caso de erro crítico, força ida pro login
          context.go(AppRoutes.login);
        },
        loading: () {},
      );
    });

    final state = ref.watch(settingsViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/back_arrow.svg',
                  width: 24,
                  height: 24,
                  placeholderBuilder: (_) => const Icon(Icons.arrow_back, color: _textGrey),
                ),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                "Settings",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w600, // Semi-bold
                  color: _textGrey,
                ),
              ),
            ),
            const Divider(height: 1, color: _borderGrey),
          ],
        ),
      ),
      // 7. Bottom Navigation (Fixo)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        //selectedItemColor: _primaryGreen,
        selectedItemColor: _iconGrey,
        unselectedItemColor: _iconGrey,
        currentIndex: 4, // Profile ativo
        onTap: (index) {
          if (index == 0) {
            // Home clivável
            context.go(AppRoutes.dashboard);
          }
          // Outros ícones inativos/placeholders
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Achievements'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3. Seção de Opções Principais
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderGrey),
              ),
              child: Column(
                children: [
                  _buildListItem("Preferences", showDivider: true),
                  _buildListItem("Notifications", showDivider: true),
                  _buildListItem("Profile", showDivider: false),
                ],
              ),
            ),

            // 4. Espaçamento Intermediário
            const SizedBox(height: 40),

            // 5. Botão de Logout
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                  // Aciona o logout
                  ref.read(settingsViewModelProvider.notifier).logout();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: _primaryGreen, // Cor do splash/press
                ),
                child: state.isLoading
                    ? const CircularProgressIndicator(color: _primaryGreen)
                    : const Text(
                  "LOGOUT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 6. Links Informativos
            _buildFooterLink("TERMS"),
            const SizedBox(height: 16),
            _buildFooterLink("PRIVACY POLICY"),
            const SizedBox(height: 16),
            _buildFooterLink("ACKNOWLEDGMENT"),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper para Itens da Lista
  Widget _buildListItem(String title, {required bool showDivider}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Navegação futura para sub-telas
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _textGrey,
                  ),
                ),
                const Icon(Icons.chevron_right, color: _iconGrey),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: _borderGrey, indent: 16, endIndent: 16),
      ],
    );
  }

  // Helper para Links do Rodapé
  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        // Navegação para webview ou página de texto
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _primaryGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}