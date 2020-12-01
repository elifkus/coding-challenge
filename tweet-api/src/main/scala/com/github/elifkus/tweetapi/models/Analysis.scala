package com.github.elifkus.tweetapi.models


case class Analysis(var identityAttack: Option[Boolean] = None,
                    var insult: Option[Boolean] = None,
                    var obscene: Option[Boolean] = None,
                    var severeToxicity: Option[Boolean] = None,
                    var sexualExplicit: Option[Boolean] = None,
                    var threat: Option[Boolean] = None,
                    var toxicity: Option[Boolean] = None
                   )