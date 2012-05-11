{-# LANGUAGE OverloadedStrings #-}
module Command.CompletionSpec (main, spec) where

import           Test.Hspec.ShouldBe

import           WindowLayout
import           Vimus (Vimus)
import           Command.Core
import           Command.Completion

main :: IO ()
main = hspecX spec

spec :: Specs
spec = do
  describe "complete" $ do
    context "with a list of commands that take no arguments" $ do

      let complete = completeCommand [
              command0 "foo"
            , command0 "bar"
            , command0 "baz"
            ]

      it "completes a command" $ do
        complete "f" `shouldBe` Right "foo "

      it "partially completes a command, on multiple matches with a common prefix" $ do
        complete "b" `shouldBe` Right "ba"

      it "gives suggestions, on multiple matches with no common prefix" $ do
        complete "ba" `shouldBe` Left ["bar", "baz"]

      it "tolerates whitespace in front of a command" $ do
        complete "  f" `shouldBe` Right "  foo "

    context "with two commands, where one is a prefix of the otehr" $ do
      let complete = completeCommand [command0 "foo", command0 "foobar"]

      it "completes only the common prefix" $ do
        complete "f" `shouldBe` Right "foo"

      context "given the common prefix as input" $ do
        it "suggests both command names" $ do
          complete "foo" `shouldBe` Left ["foo", "foobar"]

    context "with a command that takes arguments" $ do
      let complete = completeCommand [command "color" "" (undefined :: WindowColor -> Color -> Color -> Vimus ())]

      it "completes an argument" $ do
        complete "color m" `shouldBe` Right "color main "

      it "completes a second argument" $ do
        complete "color main r" `shouldBe` Right "color main red "

      it "completes a third argument" $ do
        complete "color main red gr" `shouldBe` Right "color main red green "

      it "gives suggestions for arguments" $ do
        complete "color main bl" `shouldBe` Left ["black", "blue"]

      it "tolerates whitespace" $ do
        complete "  color  main red   gr" `shouldBe` Right "  color  main red   green "
  where
    context = describe
    command0 name = command name "" (undefined :: Vimus ())
