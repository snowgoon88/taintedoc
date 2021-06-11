-- *****************************************************************************
-- *********************************************************************** LARVE
-- *****************************************************************************
cards_larve = {
   {
      id="l01",
      title="En Garde",
      closed_keys = {
      },
      closed_magic = "sequence",
      closed_free = "nothing",
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 2,
      power="END: choisissez atk de ennemi sauf repli; DEFAUSSE après atk",
   },
   {
      id="l02",
      title="Attaque",
      closed_keys = {
         agression = 1,
      },
      closed_free = 1,
      open_keys = {
         agression = 2,
         courage = 1,
      },
      open_magic = 1,
      open_free = 1,
      power="END: 1 wound; DELAY 1 card;",
   },
   {
      id="l03",
      title="Rassembler ses pensées",
      closed_keys = {
         pragmatisme = "sequence",
      },
      closed_magic = "sequence",
      closed_free = "nothing",
      open_keys = {
         courage = 1,
         pragmatisme = 1,
      },
      open_free = 2,
      power="DELAY -2, 2 card",
   },
   {
      id="l04",
      title="Coup Final",
      closed_keys = {
         agression = 2,
         courage = "sequence",
      },
      closed_magic = 1,
      closed_free = "NEG",
      open_keys = {
      },
      open_free = 0,
      power="END: -2, 1 wound",
   },
   {
      id="l05",
      title="Maléfice",
      closed_keys = {
        pragmatisme = "card",
      },
      closed_magic = 2,
      closed_free = 1,
      open_keys = {
         courage = 1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 2,
      power="INST 1 pour chaque magic_full contre violet",
   },
   {
      id="l06",
      title="Magie Guerrière",
      closed_keys = {
         agression = 1,
      },
      closed_magic = "sequence",
      closed_free = 1,
      open_keys = {
         agression =1,
         pragmatisme = 1,
      },
      open_free = 2,
      power="INST 1 terror; DELAY 2",
   },
   {
      id="l07",
      title="Repositionnement",
      closed_keys = {
      },
      closed_free = "sequence",
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 1,
      power="SI fuite NO Opportunity",
   },
   {
      id="l08",
      title="Défense",
      closed_keys = {
         pragmatisme = "sequence",
      },
      closed_magic = "sequence",
      closed_free = "nothing",
      open_keys = {
         agression =1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 2,
      power="END: -2 wound; DELAY 1 card",
   },
   {
      id="l09",
      title="Charge",
      closed_keys = {
         agression = 1,
         courage = "sequence",
      },
      closed_free = 1,
      open_keys = {
         agression =2,
         courage = 1,
      },
      open_free = 1,
      power="END: 1 wound; DELAY 1 card",
   },
   {
      id="l10",
      title="Piège Entravant",
      closed_keys = {
         pragmatisme = "sequence",
      },
      closed_magic = "sequence",
      closed_free = "card",
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_free = "NEG",
      power="END NO atk, -1, DEFAUSSE",
   },
   {
      id="l11",
      title="Trouver la Faiblesse",
      closed_keys = {
      },
      closed_magic = "sequence",
      closed_free = "card",
      open_keys = {
         pragmatisme = 2,
      },
      open_magic = 1,
      open_free = 3,
      power="END 1 wound; DELAY card",
   },
   {
      id="l12",
      title="Distraction",
      closed_keys = {
         pragmatisme = 1,
      },
      closed_free = "sequence",
      open_keys = {
         agression =1,
         courage = 1,
      },
      open_free = 1,
      power="END SI x wounds ALORS -x INSTEAD",
   },
   {
      id="l13",
      title="Attaque Prudente",
      closed_keys = {
         agression = 1,
         pragmatisme = "sequence",
      },
      closed_free = 1,
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_free = 2,
      power="END annule -1, annule 1 wound",
   },
   {
      id="l14s",
      title="Magie du Sang",
      closed_keys = {
         courage = "sequence",
      },
      closed_magic = "card",
      closed_free = "nothing",
      open_keys = {
         agression =1,
         courage = 2,
      },
      open_magic = 1,
      open_free = 1,
      power="ALWAYS + INST -1 Vie, 3 charges; charge = magie",
   },
   {
      id="l15",
      title="Attaque Risquée",
      closed_keys = {
         courage = "card",
         pragmatisme = 1,
      },
      closed_free = 1,
      open_keys = {
         agression = 2,
         pragmatisme = 2,
      },
      open_free = 1,
      power="INST p0.5 2 wound / p0.5 2",
   },
   {
      id="l14",
      title="Cris de Guerre",
      closed_keys = {
         courage = "sequence",
      },
      closed_magic = 1,
      closed_free = "card",
      open_keys = {
         agression =1,
         courage = 1,
      },
      open_free = 1,
      power="END annule 1 wound",
   },
   
   

   
