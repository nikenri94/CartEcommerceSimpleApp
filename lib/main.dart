import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data produk: nama, harga, dan path gambar
final productData = {
  'Topi': {'price': 50000, 'image': 'assets/images/topi.jpg'},
  'Jaket': {'price': 150000, 'image': 'assets/images/jaket.jpg'},
  'Jeans': {'price': 200000, 'image': 'assets/images/jeans.jpg'},
};

// Provider untuk cart
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>((
  ref,
) {
  return CartNotifier();
});

// Logika keranjang belanja
class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super({'Topi': 1, 'Jaket': 1, 'Jeans': 1});

  void increment(String item) {
    state = {...state, item: state[item]! + 1};
  }

  void decrement(String item) {
    if (state[item]! > 0) {
      state = {...state, item: state[item]! - 1};
    }
  }

  void reset() {
    state = {for (final key in state.keys) key: 0};
  }

  int get totalItems => state.values.reduce((a, b) => a + b);

  int get totalPrice {
    int total = 0;
    for (var item in state.keys) {
      total += state[item]! * (productData[item]!['price'] as int);
    }
    return total;
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce Riverpod',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: const CartPage(),
    );
  }
}

// Halaman utama keranjang
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalItems = cartNotifier.totalItems;
    final totalPrice = cartNotifier.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text('🛒 Keranjang ($totalItems barang)'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: cart.keys.map((item) {
                final qty = cart[item]!;
                final price = productData[item]!['price'] as int;
                final image = productData[item]!['image'] as String;
                final subtotal = qty * price;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Image.asset(image, width: 50, height: 50),
                    title: Text(item, style: const TextStyle(fontSize: 20)),
                    subtitle: Text('Harga: Rp$price'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => cartNotifier.decrement(item),
                        ),
                        Text('$qty', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => cartNotifier.increment(item),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rp$subtotal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              border: const Border(
                top: BorderSide(color: Colors.teal, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total Harga: Rp$totalPrice',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Checkout berhasil! Terima kasih 🛍️',
                              ),
                            ),
                          );
                          cartNotifier.reset();
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Checkout'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: cartNotifier.reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

