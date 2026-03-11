import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class FileViewerScreen extends StatefulWidget {
  final File file;
  final String fileName;
  final String fileExt;

  const FileViewerScreen({
    super.key,
    required this.file,
    required this.fileName,
    required this.fileExt,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  PDFViewController? _pdfController;

  bool get _isPdf => widget.fileExt == 'pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(color: Color(0x40D32F2F), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.fileName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      if (_isPdf && _isReady)
                        Text('Page ${_currentPage + 1} of $_totalPages',
                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.fileExt.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Expanded(child: _isPdf ? _buildPdfViewer() : _buildImageViewer()),
          if (_isPdf && _isReady && _totalPages > 1)
            Container(
              padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(icon: Icons.chevron_left_rounded, label: 'Prev', enabled: _currentPage > 0,
                      onTap: () => _pdfController?.setPage(_currentPage - 1)),
                  Row(
                    children: List.generate(_totalPages.clamp(0, 5), (i) {
                      final isActive = i == _currentPage.clamp(0, 4);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 20 : 6, height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFD32F2F) : Colors.white30,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  _NavButton(icon: Icons.chevron_right_rounded, label: 'Next', enabled: _currentPage < _totalPages - 1,
                      onTap: () => _pdfController?.setPage(_currentPage + 1)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Stack(
      children: [
        PDFView(
          filePath: widget.file.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          fitPolicy: FitPolicy.BOTH,
          onRender: (pages) => setState(() { _totalPages = pages ?? 0; _isReady = true; }),
          onViewCreated: (controller) => _pdfController = controller,
          onPageChanged: (page, total) => setState(() { _currentPage = page ?? 0; _totalPages = total ?? 0; }),
          onError: (error) => debugPrint('PDF error: $error'),
        ),
        if (!_isReady)
          const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F), strokeWidth: 2.5)),
      ],
    );
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      minScale: 0.5, maxScale: 4.0,
      child: Center(
        child: Image.file(widget.file, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.broken_image_outlined, color: Colors.white38, size: 64),
              SizedBox(height: 12),
              Text('Could not load image', style: TextStyle(color: Colors.white38)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFD32F2F).withOpacity(0.15) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: enabled ? const Color(0xFFD32F2F).withOpacity(0.4) : Colors.white12),
          ),
          child: Row(children: [
            if (icon == Icons.chevron_left_rounded) Icon(icon, color: Colors.white70, size: 20),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
            if (icon == Icons.chevron_right_rounded) Icon(icon, color: Colors.white70, size: 20),
          ]),
        ),
      ),
    );
  }
}
