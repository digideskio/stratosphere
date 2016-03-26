{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Stratosphere.Template
       ( Template (..)
       , Parameter (..)
       , Resource (..)
       , ToResource (..)
       , Output (..)
       , templateDefault

       -- Template lenses
       , formatVersion
       , description
       , metadata
       , parameters
       , mappings
       , conditions
       , resources
       , outputs

       -- Resource lenses
       , type'
       , properties

       -- Parameter lenses
       , default'
       , noEcho
       , allowedValues
       , allowedPattern
       , maxLength
       , minLength
       , maxValue
       , minValue
       , constraintDescription
       ) where

import Control.Lens
import Data.Aeson
import Data.Aeson.TH
import qualified Data.HashMap.Strict as HM
import qualified Data.Text as T
import GHC.Exts (fromList)

data Parameter =
  Parameter
  { parameterType' :: T.Text
  , parameterDefault' :: Maybe Value
  , parameterNoEcho :: Maybe Bool
  , parameterAllowedValues :: Maybe Array
  , parameterAllowedPattern :: Maybe T.Text
  , parameterMaxLength :: Maybe T.Text -- Integer
  , parameterMinLength :: Maybe T.Text -- Integer
  , parameterMaxValue :: Maybe T.Text -- Integer
  , parameterMinValue :: Maybe T.Text -- Integer
  , parameterDescription :: Maybe T.Text
  , parameterConstraintDescription :: Maybe T.Text
  } deriving (Show)

$(deriveJSON defaultOptions
  { fieldLabelModifier = drop 9 . filter (/= '\'')
  , omitNothingFields = True }
  ''Parameter)
$(makeFields ''Parameter)

type Mapping = HM.HashMap T.Text Object

data Resource =
  Resource
  { resourceType' :: T.Text
  , resourceProperties :: Object
  } deriving (Show)

$(deriveJSON defaultOptions
  { fieldLabelModifier = drop 8 . filter (/= '\'') }
  ''Resource)
$(makeFields ''Resource)

class ToResource a where
  toResource :: a -> Resource

data Output =
  Output
  { outputDescription :: T.Text
  , outputValue :: Value
  } deriving (Show)

$(deriveJSON defaultOptions { fieldLabelModifier = drop 6 } ''Output)
$(makeFields ''Output)

data Template =
  Template
  { templateFormatVersion :: Maybe T.Text
  , templateDescription :: Maybe T.Text
  , templateMetadata :: Maybe Object
  , templateParameters :: Maybe (HM.HashMap T.Text Parameter)
  , templateMappings :: Maybe (HM.HashMap T.Text Mapping)
  , templateConditions :: Maybe Object
  , templateResources :: HM.HashMap T.Text Resource
  , templateOutputs :: Maybe (HM.HashMap T.Text Output)
  } deriving (Show)

$(deriveJSON defaultOptions { fieldLabelModifier = drop 8
                            , omitNothingFields = True } ''Template)
$(makeFields ''Template)

templateDefault :: Template
templateDefault =
  Template
  { templateFormatVersion = Nothing
  , templateDescription = Nothing
  , templateMetadata = Nothing
  , templateParameters = Nothing
  , templateMappings = Nothing
  , templateConditions = Nothing
  , templateResources = fromList []
  , templateOutputs = Nothing
  }