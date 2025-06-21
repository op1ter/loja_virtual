import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import './../../controllers/controllers.dart';
import './../../widgets/widgets.dart';
import 'components/quantity_widget.dart';

class CartPage extends StatelessWidget {
  final CartController cartController = Get.find();
  final produtoController = Get.find<ProductController>();
  final userController = Get.find<UserController>();
  final authController = Get.find<AuthController>();
  final favoriteController = Get.find<FavoritosController>();
  final void Function(GlobalKey?)? cartAnimationMethod;

  CartPage({super.key, this.cartAnimationMethod});

  bool get isLogado => authController.logado.value;
  final GlobalKey imageGk = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        centerTitle: true,
        actions: [
          Obx(
            () => cartController.cartProducts.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 16, top: 12),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.orange,
                      child: Text(
                        cartController.cartProducts
                            .fold(0, (sum, item) => sum + item.quantity)
                            .toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final itens = cartController.cartProducts;

        if (itens.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Seu carrinho está vazio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adicione produtos ao carrinho para continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Continuar comprando',
                    icon: Icons.shopping_bag_outlined,
                    onPressed: () {
                      Get.offAllNamed('/');
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 4,
                  top: 6,
                  right: 2,
                  bottom: 6,
                ),
                itemCount: itens.length,
                itemBuilder: (context, index) {
                  final item = itens[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(item.imageUrl),
                          ),
                          Obx(() {
                            final isFavorito = favoriteController.isFavorito(
                              item.productId,
                            );
                            return Positioned(
                              bottom: -4,
                              right: -4,
                              child: IconButton(
                                icon: Icon(
                                  isFavorito
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorito ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (!isLogado) {
                                    Get.snackbar(
                                      'Acesso negado',
                                      'Faça login para favoritar produtos.',
                                      colorText: Colors.white,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      snackPosition: SnackPosition.TOP,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 12,
                                      icon: const Icon(
                                        Icons.lock_outline,
                                        color: Colors.white,
                                      ),
                                      duration: const Duration(seconds: 3),
                                    );
                                    return;
                                  }
                                  favoriteController.toggleFavorito(
                                    item.productId,
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(currencyFormat.format(item.price)),
                      trailing: QuantityWidget(
                        suffixText: 'Un',
                        value: item.quantity,
                        result: (quantity) {
                          cartController.atualizarquantity(
                            item.productId,
                            quantity,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: cartController.limparCarrinho,
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: const Text(
                      'Limpar Carrinho',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 15, 3, 88),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  Text(
                    'Total: ${currencyFormat.format(cartController.total)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 1.0,
                  end: cartController.cartProducts.isEmpty ? 1.0 : 1.05,
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Obx(
                  () => LoadingButton(
                    backgroundColor: Color.fromARGB(255, 15, 3, 88),
                    text: 'Finalizar Pedido',
                    icon: Icons.check_circle_outline,
                    isLoading: cartController.carregandoFinalizar.value,
                    onPressed: () async {
                      if (!isLogado) {
                        Get.snackbar(
                          'Acesso negado',
                          'Faça login para finalizar a compra.',
                          colorText: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                          icon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }

                      cartController.carregandoFinalizar.value = true;
                      await cartController.finalizarPedido();
                      cartController.clearCartBadge();
                      cartController.carregandoFinalizar.value = false;
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
