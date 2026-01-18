import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/categories_viewmodel.dart';

class CategoriesPreferencesPage extends ConsumerWidget {
  const CategoriesPreferencesPage({super.key});

  // Definição das Cores
  static const Color _greenColor = Color.fromARGB(255, 128, 188, 77);
  static const Color _textColor = Color.fromARGB(255, 112, 114, 113);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. LISTENER APENAS PARA ERROS (Snackbar)
    ref.listen(categoriesViewModelProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {

        // Limpar a fila antes de mostrar
        // Isso remove a SnackBar anterior instantaneamente, dando lugar à nova.
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Remove o prefixo "Exception: " para ficar mais limpo
            content: Text(next.error.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final state = ref.watch(categoriesViewModelProvider);

    // Tenta obter a lista de dados, mesmo que esteja em erro ou loading
    final categories = state.valueOrNull;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header (Back Button & Titles)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: IconButton(
                  //     padding: EdgeInsets.zero,
                  //     alignment: Alignment.centerLeft,
                  //     onPressed: () => context.pop(),
                  //     icon: SvgPicture.asset(
                  //       'assets/images/back_arrow.svg',
                  //       width: 24,
                  //       height: 24,
                  //       placeholderBuilder: (_) => const Icon(Icons.arrow_back),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 16),
                  Text(
                    "Which areas would you like to level up?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2,color: _textColor, fontFamily: 'Nunito'),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Choose the parts of yourself you want to grow.",
                    style: TextStyle(fontSize: 16, height: 1.4, color: _textColor, fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ),

            // 2. Categories List
            Expanded(
              child: Builder(
                builder: (context) {
                  // Se não temos dados nenhuns E está carregando -> Spinner inicial
                  if (categories == null && state.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: _greenColor));
                  }

                  // Se não temos dados E deu erro -> Mensagem de erro tela cheia
                  if (categories == null && state.hasError) {
                    return Center(child: Text("Error: ${state.error}"));
                  }

                  // Se temos dados (mesmo com erro no topo ou loading), mostramos a lista!
                  if (categories != null) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildCategoryCard(
                            category,
                                () {
                              // Só permite clicar se não estiver enviando
                              if (!state.isLoading) {
                                ref.read(categoriesViewModelProvider.notifier).toggleSelection(category.id);
                              }
                            }
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // 3. Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Botão NEXT
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: FilledButton(
                      // Desabilita visualmente se estiver loading
                      onPressed: state.isLoading
                          ? null
                          : () async {
                        // CORREÇÃO DA NAVEGAÇÃO:
                        final success = await ref.read(categoriesViewModelProvider.notifier)
                            .submitPreferences(isSelectAll: false);

                        // Só navega se retornou true
                        if (success && context.mounted) {
                          context.go(AppRoutes.dashboard);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _greenColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                          : const Text("NEXT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão SKIP (SELECT ALL)
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                        final success = await ref.read(categoriesViewModelProvider.notifier)
                            .submitPreferences(isSelectAll: true);

                        if (success && context.mounted) {
                          context.go(AppRoutes.dashboard);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text("SKIP (SELECT ALL)", style: TextStyle(color: _greenColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCategoryCard
  Widget _buildCategoryCard(dynamic category, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: category.isSelected ? _greenColor : Colors.grey.shade300,
            width: category.isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon + Name
            Expanded(
              child: Text(
                "${category.icon}  ${category.name}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  //fontWeight: FontWeight.w500,
                  fontFamily: 'Nunito',
                  color: _textColor,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Check Circle
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: category.isSelected ? _greenColor : Colors.transparent,
                border: Border.all(
                  color: category.isSelected ? _greenColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: category.isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}


