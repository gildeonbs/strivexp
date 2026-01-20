import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../../data/models/dashboard_models.dart';
import '../../../../core/router/router.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  // Cores do Figma
  static const Color _primaryGreen = Color.fromARGB(255, 128, 188, 77); // Verde padrão
  static const Color _darkGreen = Color(0xFF2E7D32); // Verde escuro
  static const Color _lightGreenBg = Color(0xFFE8F5E9); // Fundo verde claro
  static const Color _streakYellow = Color(0xFFFFC107); // Amarelo
  static const Color _errorRed = Color(0xFFE53935); // Vermelho
  static const Color _alertOrange = Color(0xFFFFA726); // Laranja

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // LISTENER DE ERROS (Snackbar)
    // Monitora o estado para exibir erros via Snackbar sem reconstruir a tela inteira
    ref.listen(dashboardViewModelProvider, (previous, next) {
      // Se houver um erro e não estiver carregando (para evitar spam enquanto tenta reconectar)
      if (next.hasError && !next.isLoading) {
        // Limpa filas anteriores para exibir o erro atual imediatamente
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Remove o prefixo "Exception: " e exibe a mensagem do backend
            content: Text(
              next.error.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            ),
            backgroundColor: _alertOrange,
            behavior: SnackBarBehavior.floating, // Flutuante
            duration: const Duration(seconds: 4), // Dá tempo de ler a mensagem longa
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });

    final state = ref.watch(dashboardViewModelProvider);

    // Se houver dados (mesmo com erro ou loading), usamos eles.
    final dashboard = state.valueOrNull;

    return Scaffold(
      backgroundColor: Colors.white,
      
      // 6. Barra de Navegação Inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Achievements'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: 0, // Home ativa
        onTap: (index) {
          // Placeholder navegação
        },
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // CENÁRIO 1: TEMOS DADOS (Sucesso ou Estado Preservado durante Erro/Load)
            if (dashboard != null) {
              return RefreshIndicator(
                color: _primaryGreen,
                onRefresh: () => ref.read(dashboardViewModelProvider.notifier).loadDashboard(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  // Physics para garantir que o scroll funcione sempre (necessário para refresh)
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Cabeçalho (Passando context para navegação)
                      _buildHeader(context, dashboard),

                      const SizedBox(height: 24),

                      // 3. Saudação e Progresso
                      _buildGreetingSection(dashboard),

                      const SizedBox(height: 24),

                      // 4. Cartão do Desafio Diário (ASSIGNED)
                      _buildDailyChallengeSection(context, ref, dashboard),

                      const SizedBox(height: 32),

                      // 5. Desafios Passados
                      _buildPastDailyChallengesSection(dashboard),
                    ],
                  ),
                ),
              );
            }

            // CENÁRIO 2: SEM DADOS E CARREGANDO (Primeiro Load)
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: _primaryGreen));
            }

            // CENÁRIO 3: SEM DADOS E COM ERRO (Erro no primeiro Load)
            if (state.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "Unable to load dashboard.\n${state.error.toString().replaceAll('Exception: ', '')}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => ref.read(dashboardViewModelProvider.notifier).loadDashboard(),
                        child: const Text("Try Again", style: TextStyle(color: _primaryGreen)),
                      )
                    ],
                  ),
                ),
              );
            }

            // Fallback
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // 2. Cabeçalho
  Widget _buildHeader(BuildContext context, DashboardModel dashboard) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 2.1 Avatar
        CircleAvatar(
          backgroundColor: _lightGreenBg,
          radius: 20,
          backgroundImage: dashboard.avatar != null ? NetworkImage(dashboard.avatar!) : null,
          child: dashboard.avatar == null
              ? const Icon(Icons.person, color: _darkGreen)
              : null,
        ),

        // 2.2 Streak
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: _streakYellow, size: 28),
              const SizedBox(width: 4),
              Text(
                "${dashboard.progress.currentStreak}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Nunito'),
              ),
            ],
          ),
        ),

        // 2.3 Settings
        IconButton(
          onPressed: () {
            context.push(AppRoutes.settings);
          },
          icon: const Icon(Icons.settings, color: Colors.grey),
        ),
      ],
    );
  }

  // 3. Saudação e Progresso
  Widget _buildGreetingSection(DashboardModel dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3.1 Texto Saudação
        Text(
          "Hi, ${dashboard.displayName}!",
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _darkGreen,
          ),
        ),
        const SizedBox(height: 8),

        // 3.2 Indicador de Nível
        Text(
          "Level ${dashboard.progress.level}: ${dashboard.progress.currentXp}/${dashboard.progress.xpForNextLevel} XP",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // 3.3 Barra de Progresso
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: dashboard.progress.progressPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  // 4. Cartão do Desafio Diário (Modificado com ícone de fundo)
  Widget _buildDailyChallengeSection(BuildContext context, WidgetRef ref, DashboardModel dashboard) {
    // Filtra desafios ASSIGNED
    final assignedChallenges = dashboard.dailyChallenges
        .where((c) => c.statusEnum == ChallengeStatus.ASSIGNED)
        .toList();

    if (assignedChallenges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _lightGreenBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "All daily challenges completed!",
            style: TextStyle(fontFamily: 'Nunito', color: _darkGreen, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final challengeItem = assignedChallenges.first;
    final challenge = challengeItem.challenge;

    return Container(
      // ClipRRect ou clipBehavior é necessário para que o emoji posicionado fora dos limites seja cortado
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _lightGreenBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // --- ÍCONE DE FUNDO (challenge.icon) ---
          Positioned(
            left: -40, // Posiciona para a esquerda para criar o efeito de corte
            //top: 20,
            bottom: -80,
            child: Opacity(
              opacity: 0.15, // Opacidade baixa para ficar sutil ao fundo
              child: Text(
                //challenge.icon ?? "🎯", // Usa o ícone do desafio ou um fallback
                challenge.icon, // Usa o ícone do desafio ou um fallback
                style: const TextStyle(
                  fontSize: 280, // Tamanho grande para ocupar a lateral
                ),
              ),
            ),
          ),

          // --- CONTEÚDO DO CARTÃO ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),

                // 4.2 Título
                Text(
                  challenge.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    color: _darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 4.3 Descrição
                Text(
                  challenge.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    color: _darkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 32),

                // 4.4 Botão COMPLETE
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(dashboardViewModelProvider.notifier).completeChallenge(challengeItem.id);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "COMPLETE CHALLENGE",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 4.5 Botão SKIP
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      ref.read(dashboardViewModelProvider.notifier).skipChallenge(challengeItem.id);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: _primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Desafios Passados
  Widget _buildPastDailyChallengesSection(DashboardModel dashboard) {
    final pastDailyChallenges = dashboard.dailyChallenges
        .where((c) => c.statusEnum != ChallengeStatus.ASSIGNED)
        .toList();

    pastDailyChallenges.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (pastDailyChallenges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 5.1 Título
        const Text(
          "Daily Challenges",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _darkGreen,
          ),
        ),
        const SizedBox(height: 16),

        // 5.2 Lista
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pastDailyChallenges.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = pastDailyChallenges[index];
            return _buildPastDailyChallengeCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildPastDailyChallengeCard(UserDailyChallengeModel item) {
    Color iconBgColor;
    IconData iconData;
    Color borderColor;

    // Lógica visual baseada no status
    switch (item.statusEnum) {
      case ChallengeStatus.COMPLETED:
        iconBgColor = _primaryGreen;
        iconData = Icons.check;
        borderColor = Colors.grey.shade200;
        break;
      case ChallengeStatus.FAILED:
        iconBgColor = _errorRed;
        iconData = Icons.close;
        borderColor = _errorRed.withOpacity(0.3);
        break;
      case ChallengeStatus.SKIPPED:
        iconBgColor = _alertOrange;
        iconData = Icons.priority_high; // Alerta
        borderColor = _alertOrange.withOpacity(0.3);
        break;
      default:
        iconBgColor = Colors.grey;
        iconData = Icons.help;
        borderColor = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Ícone circular
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.challenge.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                Text(
                  item.challenge.description,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}