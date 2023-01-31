enum PSize {
  medium, //normal size text
  bold, //only bold text
  boldMedium, //bold with medium
  boldLarge, //bold with large
  extraLarge //extra large
}

enum PAlign {
  left, //ESC_ALIGN_LEFT
  center, //ESC_ALIGN_CENTER
  right, //ESC_ALIGN_RIGHT
}

extension PrintSize on PSize {
  int get val {
    switch (this) {
      case PSize.medium:
        return 0;
      case PSize.bold:
        return 1;
      case PSize.boldMedium:
        return 2;
      case PSize.boldLarge:
        return 3;
      case PSize.extraLarge:
        return 4;
      default:
        return 0;
    }
  }
}

extension PrintAlign on PAlign {
  int get val {
    switch (this) {
      case PAlign.left:
        return 0;
      case PAlign.center:
        return 1;
      case PAlign.right:
        return 2;
      default:
        return 0;
    }
  }
}