import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'printer_config.dart';

class EscPosUtilsMethods {
  static Future<Generator> getGenerator() async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');

    if (PrinterConfig.isThreeInchPrinter) {
      return Generator(PaperSize.mm80, profile);
    } else {
      return Generator(PaperSize.mm58, profile);
    }
  }

  static List<int> printLine({required Generator generator}) {
    String line = PrinterConfig.isThreeInchPrinter ? "------------------------------------------------" : '--------------------------------';
    return generator.text(line, styles: PosStyles(align: PosAlign.center));
  }

  static List<int> printHeading(
      {required Generator generator,
      required String heading,
      bool bold = true,
      PosTextSize width = PosTextSize.size2,
      PosTextSize height = PosTextSize.size1}) {
    return generator.text(heading, styles: PosStyles(bold: bold, align: PosAlign.center, width: width, height: height));
  }

  static List<int> printRows(
      {required List<List<String>> columns, required List<int> width, required Generator generator, bool bold = false, int lineCutLength = 28}) {
    List<int> bytes = [];
    List<List<String>> newColumn = [];
    for (List<String> singleRow in columns) {
      //cut lines
      int offset = 0; // each time you add a new character, string has "shifted"
      for (int i = lineCutLength; i + offset < singleRow[0].length; i += lineCutLength) {
        // take first part of string, add a new line, and then add second part
        singleRow[0] = "${singleRow[0].substring(0, i + offset)}\n${singleRow[0].substring(i + offset)}";
        offset++;
      }

      List splittedLines = singleRow[0].split('\n');
      if (splittedLines.isEmpty) {
        newColumn.add(singleRow);
      } else {
        for (int i = 0; i < splittedLines.length; i++) {
          if (i == 0) {
            newColumn.add(["${splittedLines[i]}"] + (List.generate(singleRow.length - 1, (index) => singleRow[index + 1])));
          } else {
            newColumn.add(["${splittedLines[i]}"] + List.generate(singleRow.length - 1, (index) => ' '));
          }
        }
      }
    }

    // for (List<String> singleRow in columns) {
    //   void recFunc(str) {
    //     if (str.length > 14) {
    //       newColumn.add([str, ' ', ' ', ' ']);
    //       recFunc(str.substring(15));
    //     } else {
    //       newColumn.add([str, ' ', ' ', ' ']);
    //     }
    //   }
    //
    //   newColumn.add(singleRow);
    //   if (singleRow[0].length > 14) {
    //     recFunc(singleRow[0].substring(15));
    //   }
    // }

    for (List<String> singleRow in newColumn) {
      bytes += generator.row(List.generate(singleRow.length, (index) {
        return PosColumn(
            text: singleRow[index],
            width: width[index],
            styles: PosStyles(
              bold: bold,
              align: index == 0
                  ? PosAlign.left
                  : (index == singleRow.length - 1)
                      ? PosAlign.right
                      : PosAlign.center,
            ));
      }));
    }
    return bytes;
  }
}
