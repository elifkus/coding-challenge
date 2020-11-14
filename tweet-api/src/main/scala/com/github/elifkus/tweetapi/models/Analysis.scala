package com.github.elifkus.tweetapi.models


case class Analysis(identityAttack: Boolean,
                    insult: Boolean,
                    obscene: Boolean,
                    severeToxicity: Boolean,
                    sexualExplicit: Boolean,
                    threat: Boolean,
                    toxicity: Boolean
                   )