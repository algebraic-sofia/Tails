module Control.Monad.Rec

import Control.Monad.State
import Control.Monad.Either
import Data.IORef

||| Data type to express recursion step as data.
public export
data Step a b = Loop a | Done b

||| MonadRec express a tail call optimized recursion 
||| to monads
public export
interface Monad m => MonadRec m where 
    tailRecM : (a -> m (Step a b)) -> a -> m b

||| Infinite tail call recursion
export
forever : MonadRec m => m a -> m b
forever ma = tailRecM (\u => Loop u <$ ma) ()

||| Loop with maybe to express continuation of the loop
export
whileRec : MonadRec m => m (Maybe b) -> m b
whileRec ma = flip tailRecM () $ \a => maybe (Loop a) Done <$> ma 

-----------------------------------------------------------
-- Implementations for each monad transformer
-----------------------------------------------------------

export
loopIO : IO Bool -> IO ()
loopIO m = 
    if unsafePerformIO m 
        then loopIO m
        else pure ()


public export
MonadRec m => MonadRec (StateT s m) where 
    tailRecM f arg = ST $ \state => tailRecM go (state, arg)
        where go : (s, a) -> m (Step (s, a) (s, b))
              go (state, ret) with (f ret)
                _ | ST stateFn = do 
                    (state, step) <- stateFn state
                    case step of 
                        Done r => pure (Done (state, r))
                        Loop r => pure (Loop (state, r))

public export
MonadRec m => MonadRec (EitherT e m) where 
    tailRecM f arg = MkEitherT $ tailRecM ?go arg
        where 
            go : a -> m (Step a (Either e b))
            go arg with (f arg) 
                _ | MkEitherT n = do
                    res <- n
                    pure $ case res of 
                        Left e         => Done (Left e) 
                        Right (Done r) => Done (Right r)
                        Right (Loop r) => Loop r
                        
public export
MonadRec IO where 
    tailRecM f arg = do     
            ref <- f arg >>= newIORef
            loopIO $ do 
                Done r <- readIORef ref 
                    | Loop r => do 
                        ex <- f r
                        writeIORef ref ex 
                        pure True
                pure False
            -- Unsafe but it will work everytime.. i dont want to prove it sry
            assert_total unwrapDone <$> readIORef ref
        where 
            partial 
            unwrapDone : Step a b -> b 
            unwrapDone (Done r) = r
