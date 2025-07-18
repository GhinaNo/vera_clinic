import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../model/offersModel.dart';
import '../widgets/offers_card.dart';
import 'AddOrEditOffer_page.dart';


enum OfferFilter { all, active, expired }

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<Offer> offers = [];
  OfferFilter selectedFilter = OfferFilter.all;

  List<Offer> get filteredOffers {
    if (selectedFilter == OfferFilter.all) return offers;
    final now = DateTime.now();
    if (selectedFilter == OfferFilter.active) {
      return offers.where((o) => o.endDate.isAfter(now)).toList();
    }
    return offers.where((o) => o.endDate.isBefore(now)).toList();
  }

  void _addOffer(Offer offer) {
    setState(() => offers.add(offer));
  }

  void _updateOffer(int index, Offer updated) {
    setState(() => offers[index] = updated);
  }

  void _removeOffer(int index) {
    setState(() => offers.removeAt(index));
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء',style: TextStyle(color: AppColors.purple)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد', style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  border: Border.all(color: AppColors.purple),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<OfferFilter>(
                  value: selectedFilter,
                  underline: const SizedBox(),
                  style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold),
                  dropdownColor: AppColors.offWhite,
                  items: const [
                    DropdownMenuItem(
                        value: OfferFilter.all, child: Text('الكل')),
                    DropdownMenuItem(
                        value: OfferFilter.active, child: Text('مفعلة')),
                    DropdownMenuItem(
                        value: OfferFilter.expired, child: Text('منتهية')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedFilter = value);
                  },
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final newOffer = await Navigator.push<Offer>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddOrEditOfferPage()),
                    );
                    if (newOffer != null) _addOffer(newOffer);
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('عرض جديد', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredOffers.isEmpty
                ? const Center(child: Text('لا يوجد عروض'))
                : ListView.builder(
              itemCount: filteredOffers.length,
              itemBuilder: (context, index) {
                final offer = filteredOffers[index];
                return OfferCard(
                  offer: offer,
                  onEdit: () async {
                    final updated = await Navigator.push<Offer>(
                      context,
                      MaterialPageRoute(builder: (_) => AddOrEditOfferPage(offer: offer)),
                    );
                    if (updated != null) _updateOffer(index, updated);
                  },
                  onDelete: () async {
                    final confirm = await _showConfirmDialog('تأكيد الحذف', 'هل أنت متأكد من حذف العرض؟');
                    if (confirm == true) _removeOffer(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
