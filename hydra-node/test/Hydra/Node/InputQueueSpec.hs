module Hydra.Node.InputQueueSpec where

import Hydra.Prelude

import Control.Monad.IOSim (IOSim, runSimOrThrow)
import Hydra.API.ServerSpec (strictlyMonotonic)
import Hydra.Node.InputQueue (Queued (queuedId), createInputQueue, dequeue, enqueue)
import Test.Hspec (Spec)
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (NonEmptyList (NonEmpty), Property, counterexample)

spec :: Spec
spec =
  prop "adds sequential id to all events enqueued" prop_identify_enqueued_events

newtype DummyInput = DummyInput Int
  deriving newtype (Eq, Show, Arbitrary)

prop_identify_enqueued_events :: NonEmptyList Int -> Property
prop_identify_enqueued_events (NonEmpty inputs) =
  let test :: IOSim s [Word64]
      test = do
        q <- createInputQueue
        forM inputs $ \i -> do
          enqueue q i
          queuedId <$> dequeue q
      ids = runSimOrThrow test
   in strictlyMonotonic ids
        & counterexample ("queued ids: " <> show ids)
