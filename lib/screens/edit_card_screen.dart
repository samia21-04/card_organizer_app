import 'package:flutter/material.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';

class EditCardScreen extends StatefulWidget {
  final int folderId;
  final PlayingCard? existing;

  const EditCardScreen({
    super.key,
    required this.folderId,
    required this.existing,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final CardRepository _cardRepo = CardRepository();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _imageController = TextEditingController();
  String _suit = 'Hearts';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.cardName;
      _imageController.text = widget.existing!.imageUrl ?? '';
      _suit = widget.existing!.suit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final card = PlayingCard(
      id: widget.existing?.id,
      cardName: _nameController.text.trim(),
      suit: _suit,
      imageUrl: _imageController.text.trim(),
      folderId: widget.folderId,
    );

    try {
      if (widget.existing == null) {
        await _cardRepo.insertCard(card);
      } else {
        await _cardRepo.updateCard(card);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save failed. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Card' : 'Add Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Card name (Ace, 2, King...)',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _suit,
                decoration: const InputDecoration(labelText: 'Suit'),
                items: const [
                  DropdownMenuItem(value: 'Hearts', child: Text('Hearts')),
                  DropdownMenuItem(value: 'Spades', child: Text('Spades')),
                  DropdownMenuItem(value: 'Diamonds', child: Text('Diamonds')),
                  DropdownMenuItem(value: 'Clubs', child: Text('Clubs')),
                ],
                onChanged: (v) => setState(() => _suit = v ?? 'Hearts'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image path or URL',
                  hintText: 'assets/cards/AS.png or https://...',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(editing ? 'Update' : 'Save'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}