import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class MyWidget extends StatefulWidget
{
	@override
	State<StatefulWidget> createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> 
{
	Completer<bool> loader;
	ui.Image image;

	@override
	void initState()
	{
		super.initState();
		loader = Completer();
		loadImage();
	}

	@override
	void dispose() {
		image.dispose();
		super.dispose();
	}

	ui.Picture getPicture(ui.Image img)
	{
		final recorder = ui.PictureRecorder();
		final dimension = Size(img.width.toDouble(), img.height.toDouble());
		final cullRect = Offset.zero & dimension;
		Canvas canvas = Canvas(recorder, cullRect);
		canvas.drawImage(img, Offset.zero, Paint());
		return recorder.endRecording();
	}

	void export()
	{
		debugPrint("Export image");
		final picture = getPicture(image);
		picture.toImage(image.width, image.height).then((image) {
			picture.dispose();
			image.toByteData().then((bytes) {
				debugPrint("Export completed!");
			});
		});
	}

	void loadImage()
	{
		debugPrint("Loading image");
		rootBundle.load("asset/image.jpg").then((bytes) {
			ui.decodeImageFromList(bytes.buffer.asUint8List(), (ui.Image img) {
				debugPrint("Load image completed ${bytes.buffer.lengthInBytes} bytes");
				image = img;
				loader.complete(true);
			});
		});
	}

	@override
	Widget build(BuildContext context) =>
	Scaffold(
		appBar: AppBar(title: Text("Sample")),
		body: FutureBuilder<bool>(
			future: loader.future,
			builder: (_, AsyncSnapshot<bool> snapshot) {
				if (!snapshot.hasData) {
					return Container(
						child: Center(child: CircularProgressIndicator())
					);
				}

				return LayoutBuilder(
					builder: (_, BoxConstraints constraints) {
						return ConstrainedBox(
							constraints: BoxConstraints.expand(),
							child: ClipRect(
								child: CustomPaint(
									isComplex: true,
									painter: _DrawingPainter(image: image),
								)
							)
						);
					}
				);
			}
		),
		floatingActionButton: FloatingActionButton(
			child: const Icon(Icons.play_circle_outline),
			onPressed: export,
		)
	);
}


class _DrawingPainter extends CustomPainter
{
	final ui.Image image;
	const _DrawingPainter({this.image});

	@override
	void paint(Canvas canvas, Size size) {
		// debugPrint("Canvas size $size: Image ${image.width} x ${image.height}");
		// canvas.drawColor(Colors.red, BlendMode.lighten);
		canvas.save();
		// canvas.drawImage(image, Offset.zero, Paint());		
		canvas.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), Rect.fromLTWH(0, 0, 400, 400), Paint());
		canvas.restore();
	}

	@override
	bool shouldRepaint(_DrawingPainter oldPainter) => true;
}