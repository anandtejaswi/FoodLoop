// ============================================================
// screens/giver/post_food_screen.dart
// Widgets: Scaffold, AppBar, Form, TextFormField, DropdownButtonFormField,
//          ElevatedButton, SingleChildScrollView, Column, Row,
//          GestureDetector, Container, DateTimePicker, Image,
//          CircularProgressIndicator, SizedBox, Padding, Text
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';

class PostFoodScreen extends StatefulWidget {
  const PostFoodScreen({super.key});

  @override
  State<PostFoodScreen> createState() => _PostFoodScreenState();
}

class _PostFoodScreenState extends State<PostFoodScreen> {
  // ── Form key for validation ───────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ──────────────────────────────────────
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _addressCtrl  = TextEditingController();
  final _phoneCtrl    = TextEditingController();

  // ── State vars ────────────────────────────────────────────
  String _category = 'meals';
  String _quantityUnit = 'portions';
  DateTime _expiryTime = DateTime.now().add(const Duration(hours: 6));
  XFile? _pickedFile;
  Uint8List? _imageBytes;
  double? _lat, _lng;
  bool _locating = false;
  bool _saving   = false;

  static const List<String> _categories   = ['meals', 'produce', 'bakery', 'dairy', 'other'];
  static const List<String> _units        = ['portions', 'kg', 'litres', 'boxes', 'bags', 'pieces'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _quantityCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Pick image from gallery ───────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  // ── Get current GPS location via OSM ─────────────────────
  Future<void> _detectLocation() async {
    setState(() => _locating = true);
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos == null) {
      setState(() => _locating = false);
      return;
    }
    final address = await LocationService.instance.reverseGeocode(pos.latitude, pos.longitude);
    setState(() {
      _lat     = pos.latitude;
      _lng     = pos.longitude;
      _addressCtrl.text = address;
      _locating = false;
    });
  }

  // ── Pick expiry date/time ─────────────────────────────────
  Future<void> _pickExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_expiryTime));
    if (time == null) return;
    setState(() => _expiryTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  // ── Submit form ───────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please detect your location first.'), backgroundColor: AppTheme.error),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      await ApiService.instance.postFoodItem({
        'title':        _titleCtrl.text.trim(),
        'description':  _descCtrl.text.trim(),
        'category':     _category,
        'quantity':     int.tryParse(_quantityCtrl.text) ?? 1,
        'quantity_unit': _quantityUnit,
        'lat':          _lat,
        'lng':          _lng,
        'address':      _addressCtrl.text.trim(),
        'expiry_time':  _expiryTime.toIso8601String(),
        'giver_phone':  _phoneCtrl.text.trim(),
      }, token, imageBytes: _imageBytes, imageFilename: _pickedFile?.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food posted successfully! 🎉'), backgroundColor: AppTheme.success),
      );
      context.go(AppRoutes.giverDashboard);
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  // ── Section label builder ─────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
  );

  @override
  Widget build(BuildContext context) {
    // Scaffold – page container with AppBar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Available Food'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.giverDashboard)),
      ),

      body: Form(
        key: _formKey,
        // SingleChildScrollView – makes form scrollable
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Photo picker ────────────────────────────
              _label('Food Photo'),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity, height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    image: _imageBytes != null
                        ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageBytes == null
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 44, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('Tap to upload photo', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade500)),
                        ])
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              // ── Food title ────────────────────────────────
              _label('Food Title *'),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Leftover Dal & Rice', prefixIcon: Icon(Icons.fastfood_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),

              // ── Category dropdown ─────────────────────────
              _label('Category *'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1), style: const TextStyle(fontFamily: 'Poppins')))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),

              const SizedBox(height: 16),

              // ── Quantity row ──────────────────────────────
              _label('Quantity *'),
              Row(
                children: [
                  // TextFormField – quantity number
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '1', prefixIcon: Icon(Icons.numbers_outlined)),
                      validator: (v) => (v == null || int.tryParse(v) == null || int.parse(v) < 1) ? 'Enter valid quantity' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // DropdownButton – unit selector
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: _quantityUnit,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.straighten_outlined)),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontFamily: 'Poppins')))).toList(),
                      onChanged: (v) => setState(() => _quantityUnit = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Description ───────────────────────────────
              _label('Description'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Dietary info, allergens, pickup instructions…', alignLabelWithHint: true, prefixIcon: Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(Icons.notes_outlined))),
              ),

              const SizedBox(height: 16),

              // ── Pickup location ───────────────────────────
              _label('Pickup Location *'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(hintText: 'Address', prefixIcon: Icon(Icons.place_outlined)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ElevatedButton – GPS detect button
                  ElevatedButton(
                    onPressed: _locating ? null : _detectLocation,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(52, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _locating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.my_location_rounded, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Expiry picker ─────────────────────────────
              _label('Available Until *'),
              GestureDetector(
                onTap: _pickExpiry,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppTheme.giverPrimary),
                      const SizedBox(width: 12),
                      Text(DateFormat('EEE, dd MMM – hh:mm a').format(_expiryTime),
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.textPrimary)),
                      const Spacer(),
                      const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Contact phone number ───────────────────────────
              _label('Your Phone Number *'),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'e.g. +91 98765 43210',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Phone number is required so takers can contact you'
                    : null,
              ),

              const SizedBox(height: 32),

              // ── Submit button ─────────────────────────────
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Post Food Listing'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
