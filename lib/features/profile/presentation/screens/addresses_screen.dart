
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CustomerAddress {
  final String id;
  final String title;
  final String name;
  final String phone;
  final String city;
  final String address;
  final bool isDefault;

  const CustomerAddress({
    required this.id,
    required this.title,
    required this.name,
    required this.phone,
    required this.city,
    required this.address,
    this.isDefault = false,
  });

  CustomerAddress copyWith({
    String? id,
    String? title,
    String? name,
    String? phone,
    String? city,
    String? address,
    bool? isDefault,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'phone': phone,
      'city': city,
      'address': address,
      'isDefault': isDefault,
    };
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] as String,
      title: json['title'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  static const String _storageKey = 'shopflow_addresses';

  List<CustomerAddress> _addresses = [];
  bool _isLoading = true;

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData != null) {
      try {
        final decoded = jsonDecode(savedData) as List;

        _addresses = decoded
            .map(
              (item) => CustomerAddress.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
            .toList();
      } catch (_) {
        _addresses = [];
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _addresses.map((address) => address.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _openAddressForm({
    CustomerAddress? address,
  }) async {
    final result = await showModalBottomSheet<CustomerAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => _AddressFormSheet(address: address),
    );

    if (result == null) return;

    setState(() {
      if (address == null) {
        final newAddress = result.copyWith(
          isDefault: _addresses.isEmpty,
        );
        _addresses.add(newAddress);
      } else {
        final index = _addresses.indexWhere(
              (item) => item.id == address.id,
        );

        if (index != -1) {
          _addresses[index] = result;
        }
      }
    });

    await _saveAddresses();
  }

  Future<void> _setDefault(CustomerAddress address) async {
    setState(() {
      _addresses = _addresses.map((item) {
        return item.copyWith(
          isDefault: item.id == address.id,
        );
      }).toList();
    });

    await _saveAddresses();
  }

  Future<void> _deleteAddress(CustomerAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Text(
            _isArabic ? 'حذف العنوان' : 'Delete Address',
          ),
          content: Text(
            _isArabic
                ? 'هل أنت متأكد من حذف هذا العنوان؟'
                : 'Are you sure you want to delete this address?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(_isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                _isArabic ? 'حذف' : 'Delete',
                style: TextStyle(color: colors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _addresses.removeWhere((item) => item.id == address.id);

      if (_addresses.isNotEmpty &&
          !_addresses.any((item) => item.isDefault)) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
    });

    await _saveAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: LanguageController.instance,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isArabic ? 'عناويني' : 'My Addresses',
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddressForm(),
            icon: const Icon(Icons.add),
            label: Text(_isArabic ? 'إضافة عنوان' : 'Add Address'),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _addresses.isEmpty
              ? _buildEmptyState(colors)
              : ListView.separated(
            padding: const EdgeInsets.all(
              AppSpacing.screenPadding,
            ),
            itemCount: _addresses.length,
            separatorBuilder: (_, index) =>
            const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final address = _addresses[index];

              return _AddressCard(
                address: address,
                onEdit: () => _openAddressForm(
                  address: address,
                ),
                onDelete: () => _deleteAddress(address),
                onSetDefault: () => _setDefault(address),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 75,
              color: colors.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _isArabic ? 'لا توجد عناوين محفوظة' : 'No saved addresses',
              style: AppTextStyles.headingMedium.copyWith(
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _isArabic
                  ? 'أضف عنوانك لتسهيل عملية التوصيل.'
                  : 'Add an address to make delivery easier.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final CustomerAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: address.isDefault
              ? colors.primary
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  address.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isArabic ? 'افتراضي' : 'Default',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            address.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            address.phone,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            address.city,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            address.address,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const Divider(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(_isArabic ? 'تعديل' : 'Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(
                  _isArabic ? 'حذف' : 'Delete',
                  style: TextStyle(color: colors.error),
                ),
              ),
              if (!address.isDefault)
                TextButton(
                  onPressed: onSetDefault,
                  child: Text(
                    _isArabic ? 'تعيين كافتراضي' : 'Set as Default',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final CustomerAddress? address;

  const _AddressFormSheet({this.address});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _titleController = TextEditingController(text: address?.title ?? '');
    _nameController = TextEditingController(text: address?.name ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _addressController = TextEditingController(
      text: address?.address ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || !RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
      return _isArabic
          ? 'أدخل رقم هاتف مصري صحيحًا (010، 011، 012، 015)'
          : 'Enter a valid Egyptian mobile number (010, 011, 012, 015)';
    }

    return null;
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        validator: validator ?? _validate,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppSpacing.inputRadius,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppSpacing.inputRadius,
            ),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final address = CustomerAddress(
      id: widget.address?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      isDefault: widget.address?.isDefault ?? false,
    );

    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  widget.address == null
                      ? (_isArabic ? 'إضافة عنوان جديد' : 'Add New Address')
                      : (_isArabic ? 'تعديل العنوان' : 'Edit Address'),
                  style: AppTextStyles.headingSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildField(
                  label: _isArabic ? 'اسم العنوان (المنزل، العمل)' : 'Address Title (Home, Work)',
                  controller: _titleController,
                ),
                _buildField(
                  label: _isArabic ? 'الاسم بالكامل' : 'Full Name',
                  controller: _nameController,
                ),
                _buildField(
                  label: _isArabic ? 'رقم الهاتف' : 'Phone Number',
                  controller: _phoneController,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                ),
                _buildField(
                  label: _isArabic ? 'المدينة' : 'City',
                  controller: _cityController,
                ),
                _buildField(
                  label: _isArabic ? 'العنوان بالتفصيل' : 'Full Address',
                  controller: _addressController,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      _isArabic ? 'حفظ العنوان' : 'Save Address',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
