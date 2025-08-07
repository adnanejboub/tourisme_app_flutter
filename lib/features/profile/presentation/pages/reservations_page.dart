import 'package:flutter/material.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: Replace with real reservation check
    final bool hasReservations = false;
    final reservations = <String>[]; // Placeholder

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reservations'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: hasReservations
          ? ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: reservations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  reservations[index],
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration (replace with your asset if available)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Icon(Icons.card_travel, size: 100, color: theme.colorScheme.primary),
                    ),
                    Text(
                      "No reservations yet? Let's fix that!",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Book before you go to discover the best on site.",
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/explore'),
                        child: const Text(
                          'Start planning',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
