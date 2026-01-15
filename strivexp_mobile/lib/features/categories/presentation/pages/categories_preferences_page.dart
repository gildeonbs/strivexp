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
    // Escuta o provider para navegação e erros
    ref.listen(categoriesViewModelProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading && next.hasValue) {
        // Se saiu de loading e tem valor, foi um sucesso no submit
        // Nota: Precisamos distinguir "load inicial" de "submit". 
        // Em um app real, usaríamos um state object mais complexo.
        // Assumindo que o submit foi chamado manualmente, navegamos.
        // Para simplificar aqui: se o usuário clicar no botão, ele espera navegar.
        // Vamos deixar a navegação no callback do botão ou usar um boolean "isSubmitted" no provider.
        
        // Porem, como o _loadCategories roda no inicio, ele tbm dispara isso.
        // Vamos gerenciar a navegação manualmente no onPressed para garantir,
        // ou checar se foi uma ação de escrita.
      }
      
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(categoriesViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             // 1. Header (Back Button & Titles)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () => context.pop(),
                      icon: SvgPicture.asset(
                        'assets/images/back_arrow.svg',
                        width: 24,
                        height: 24,
                        placeholderBuilder: (_) => const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Which areas would you like to level up?",
                    style: TextStyle(
                      fontSize: 24,
                      color: _textColor,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Choose the parts of yourself you want to grow.",
                    style: TextStyle(
                      fontSize: 16,
                      color: _textColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Categories List
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator(color: _greenColor)),
                error: (err, _) => Center(child: Text("Error: $err")),
                data: (categories) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(
                        category, 
                        () => ref.read(categoriesViewModelProvider.notifier).toggleSelection(category.id)
                      );
                    },
                  );
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
                      onPressed: state.isLoading 
                        ? null 
                        : () async {
                            await ref.read(categoriesViewModelProvider.notifier).submitPreferences(isSelectAll: false);
                            if (context.mounted) context.go(AppRoutes.home);
                          },
                      style: FilledButton.styleFrom(
                        backgroundColor: _greenColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "NEXT",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        ),
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
                             await ref.read(categoriesViewModelProvider.notifier).submitPreferences(isSelectAll: true);
                             if (context.mounted) context.go(AppRoutes.home);
                          },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey), // Borda cinza
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        "SKIP (SELECT ALL)",
                        style: TextStyle(
                          color: _greenColor, // Texto verde
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
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

  Widget _buildCategoryCard(category, VoidCallback onTap) {
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
                  color: _textColor,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Check Circle
            Container(
              width: 24,
              height:24,
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


