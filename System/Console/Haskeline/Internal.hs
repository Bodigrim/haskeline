module System.Console.Haskeline.Internal
    ( debugTerminalKeys ) where

import Control.Monad (forever)
import System.Console.Haskeline (defaultSettings, outputStrLn)
import System.Console.Haskeline.Command
import System.Console.Haskeline.InputT
import System.Console.Haskeline.LineState
import System.Console.Haskeline.Monads
import System.Console.Haskeline.RunCommand
import System.Console.Haskeline.Term

-- | This function may be used to debug Haskeline's input.
--
-- It loops indefinitely; every time a key is pressed, it will
-- print that key as it was recognized by Haskeline.
-- Pressing Ctrl-C will stop the loop.
--
-- Haskeline's behavior may be modified by editing your @~/.haskeline@
-- file.  For details, see: <https://github.com/judah/haskeline/wiki/CustomKeyBindings>
--
debugTerminalKeys :: IO ()
debugTerminalKeys = runInputT defaultSettings $ do
    outputStrLn
        "Press any keys to debug Haskeline's input, or ctrl-c to exit:"
    rterm <- InputT ask
    case termOps rterm of
        Right _ -> error "debugTerminalKeys: not run in terminal mode"
        Left tops -> forever $ getKey tops >>= outputStrLn . show
  where
    getKey tops = runInputCmdT tops
                    $ runCommandLoop tops prompt getKeyCmd emptyIM
    getKeyCmd = KeyMap $ \k -> Just $ Consumed $ const $ return k
    prompt = stringToGraphemes "> "
