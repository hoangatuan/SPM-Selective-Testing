 //
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import TSCBasic
import TSCUtility

let terminalController = TerminalController(stream: stdoutStream)

public func log(
    message: @autoclosure () -> String,
    color: TerminalController.Color = .noColor,
    needEndline: Bool = true,
    isBold: Bool = false
) {
#if DEBUG
    debugPrint(message())
#else
    terminalController?.write(message(), inColor: color, bold: isBold)
    
    if needEndline {
        terminalController?.endLine()
    }
#endif
}
