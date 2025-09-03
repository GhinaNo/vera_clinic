import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/offer_cubit.dart';
import '../cubit/offer_state.dart';
import '../model/offersModel.dart';
import '../widgets/offers_card.dart';
import '../../services/cubit/ServicesCubit.dart';
import '../../../core/widgets/custom_toast.dart';
import 'AddOrEditOffer_page.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Future<bool?> _showConfirmDialog(
      BuildContext context, String title, String content) {
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    /// جلب العروض عند الدخول
    context.read<OffersCubit>().loadOffers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OffersCubit, OffersState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          showCustomToast(context, state.successMessage!, success: true);
        }
        if (state.errorMessage != null) {
          showCustomToast(context, state.errorMessage!);
        }
      },
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
                      value: state.filter,
                      underline: const SizedBox(),
                      style: const TextStyle(
                          color: AppColors.purple, fontWeight: FontWeight.bold),
                      dropdownColor: AppColors.offWhite,
                      items: const [
                        DropdownMenuItem(value: OffersFilter.all, child: Text('الكل')),
                        DropdownMenuItem(value: OffersFilter.active, child: Text('مفعلة')),
                        DropdownMenuItem(value: OffersFilter.expired, child: Text('منتهية')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<OffersCubit>().setFilter(value);
                          _controller..reset()..forward();
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final newOffer = await Navigator.push<Offer>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ServicesCubit>(),
                            child: AddOrEditOfferPage(), // ✅ بدون const
                          ),
                        ),
                      );
                      if (newOffer != null) {
                        context.read<OffersCubit>().addOffer(newOffer);
                        _controller..reset()..forward();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('عرض جديد', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
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
                    final start = index * 0.1;
                    final end = start + 0.5;
                    final animation = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        start < 1.0 ? start : 1.0,
                        end < 1.0 ? end : 1.0,
                        curve: Curves.easeOut,
                      ),
                    );

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: OfferCard(
                          offer: offer,
                          onEdit: () async {
                            final updated = await Navigator.push<Offer>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ServicesCubit>(),
                                  child: AddOrEditOfferPage(offer: offer), // ✅ بدون const
                                ),
                              ),
                            );
                            if (updated != null) {
                              context.read<OffersCubit>().updateOffer(updated);
                            }
                          },
                          onDelete: () async {
                            final confirm = await _showConfirmDialog(
                                context, 'تأكيد الحذف', 'هل أنت متأكد من حذف العرض؟');
                            if (confirm == true) {

                              context.read<OffersCubit>().deleteOffer(offer.id);
                              print("doneeee");
                            }
                          },
                        ),
                      ),
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
