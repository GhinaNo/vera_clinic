import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/offer_cubit.dart';
import '../model/offersModel.dart';
import '../widgets/offers_card.dart';
import 'AddOrEditOffer_page.dart';

import '../cubit/offer_state.dart';
import '../../services/cubit/ServicesCubit.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.purple)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  OffersFilter _toOfferFilter(OffersFilter filter) {
    switch (filter) {
      case OffersFilter.active:
        return OffersFilter.active;
      case OffersFilter.expired:
        return OffersFilter.expired;
      case OffersFilter.all:
      default:
        return OffersFilter.all;
    }
  }

  OffersFilter _toOffersFilter(OffersFilter filter) {
    switch (filter) {
      case OffersFilter.active:
        return OffersFilter.active;
      case OffersFilter.expired:
        return OffersFilter.expired;
      case OffersFilter.all:
      default:
        return OffersFilter.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
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
                    child: DropdownButton<OffersFilter>(
                      value: _toOfferFilter(state.filter),
                      underline: const SizedBox(),
                      style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold),
                      dropdownColor: AppColors.offWhite,
                      items: const [
                        DropdownMenuItem(value: OffersFilter.all, child: Text('الكل')),
                        DropdownMenuItem(value: OffersFilter.active, child: Text('مفعلة')),
                        DropdownMenuItem(value: OffersFilter.expired, child: Text('منتهية')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<OffersCubit>().setFilter(_toOffersFilter(value));
                        }
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
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ServicesCubit>(),
                              child: const AddOrEditOfferPage(),
                            ),
                          ),
                        );
                        if (newOffer != null) {
                          context.read<OffersCubit>().addOffer(newOffer);
                        }
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
                child: state.filteredOffers.isEmpty
                    ? const Center(child: Text('لا يوجد عروض'))
                    : ListView.builder(
                  itemCount: state.filteredOffers.length,
                  itemBuilder: (context, index) {
                    final offer = state.filteredOffers[index];
                    return OfferCard(
                      offer: offer,
                      onEdit: () async {
                        final updated = await Navigator.push<Offer>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ServicesCubit>(),
                              child: AddOrEditOfferPage(offer: offer),
                            ),
                          ),
                        );
                        if (updated != null) {
                          context.read<OffersCubit>().updateOffer(updated);
                        }
                      },
                      onDelete: () async {
                        final confirm = await _showConfirmDialog(context, 'تأكيد الحذف', 'هل أنت متأكد من حذف العرض؟');
                        if (confirm == true) {
                          context.read<OffersCubit>().deleteOffer(offer);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
