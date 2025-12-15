/*
 *  vocal_ivy -> Demonstration with ivy middleware
 * v. 1.2
 * 
 * (c) Ph. Truillet, October 2018-2019
 * Last Revision: 22/09/2020
 * Gestion de dialogue oral
 * Modifié par Eliot PAZZÉ
 */
 
import fr.dgac.ivy.*;
import java.util.Iterator;

// data

Ivy bus;
Ivy busIcar;
PFont f;
String message= "";
String messageIcar= "";

int state;
public static final int INIT = 0;
public static final int ATTENTE = 1;
public static final int TEXTE = 2;
public static final int CONCEPT = 3;
public static final int NON_RECONNU = 4;


private Commande commande;
int stateCommande;

public static final int INIT_COMMANDE = 0;
public static final int ORDRE_DONNE = 1;
Forme formeSelectionnee = null;
boolean moveEnCours = false;
Forme formeCopie = null;
boolean copieEnCours = false;

ArrayList<Forme> listeFormes;


void setup()
{
  size(800,800);
  fill(0,0,0);
  state = INIT;
  commande = new Commande(null,null,null,null);
  stateCommande = 0;
  listeFormes = new ArrayList<>();
  try
  {
    bus = new Ivy("sra5", " sra_tts_bridge is ready", null);
    busIcar = new Ivy("ICAR", " ICAR_bridge is ready", null);
    bus.start("127.255.255.255:2010");
    busIcar.start("127.255.255.255:2010");
    
    bus.bindMsg("^sra5 Text=(.*) Confidence=.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Vous avez dit : " + args[0];
        state = TEXTE;
      }        
    });
    
    bus.bindMsg("^sra5 Parsed=(.*) Confidence=(.*) NP=.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Vous avez prononcé les concepts : " + args[0] + " avec un taux de confiance de " + args[1];
        state = CONCEPT;
      }        
    });
    
    bus.bindMsg("^sra5 Event=Speech_Rejected", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Malheureusement, je ne vous ai pas compris"; 
        state = NON_RECONNU;
      }        
    });   
    
    busIcar.bindMsg("^ICAR Gesture=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        messageIcar = args[0];
      }        
    });
  }
  catch (IvyException ie)
  {
  }
}

void draw() {
  background(255);

  if (moveEnCours && formeSelectionnee != null) {
    formeSelectionnee.setLocation(new Point(mouseX, mouseY));
  }

  if (message != null) {
    if (!message.contains("action=undefined") && message.contains("action=")) {
      commande.setAction(handleAction(message));
    }
    if (!message.contains("form=undefined") && message.contains("form=")) {
      commande.setForme(handleForme(message));
    }
    if (!message.contains("color=undefined") && message.contains("color=")) {
      commande.setCouleur(handleCouleur(message));
    }
    if (!message.contains("localisation=undefined") && message.contains("localisation=")) {
      commande.setLieu(handleLieu(message));
    }

    Point mousePoint = new Point(mouseX, mouseY);
    
    if (messageIcar != null) {
      commande.setForme(messageIcar.toUpperCase());
      messageIcar = null;
    }

    if (commande.getAction() != null) {
      switch (commande.getAction()) {
        case "CREATE":
          if (commande.getForme() != null && !commande.getForme().equals("") && !commande.getForme().equals("none")) {
            if (commande.getLieu() != null && !commande.getLieu().equals("none")) {
              listeFormes.add(commande.commandToForme(mousePoint.x, mousePoint.y));
            } 
          } else {
            listeFormes.add(commande.commandToForme(mousePoint.x, mousePoint.y));
          }
          break;

        case "DELETE":
          handleDelete(mousePoint);
          break;

        case "MOVE":
          handleMove(mousePoint);
          break;

        case "MODIFY":
          handleModify(mousePoint);
          break;
        
        case "COPY":
        handleCopy(mousePoint);
      }
    }

    commande = new Commande(null, null, null, null);
    message = null;
  }

  for (Forme f : listeFormes) {
    f.update();
  }

  state = ATTENTE;
}


//Methodes handleCommande
String handleAction(String message){
  message=message.split("action=")[1];
  message=message.split(" ")[0];
  return message;
}

String handleForme(String message){
  message=message.split("form=")[1];
  message=message.split(" ")[0];
  return message;
}

String handleCouleur(String message){
  message=message.split("color=")[1];
  message=message.split(" ")[0];
  return message;
}

String handleLieu(String message){
  message=message.split("localisation=")[1];
  message=message.split(" ")[0];
  return message;
}

void handleDelete(Point pMouse) {
  Iterator<Forme> iterator = listeFormes.iterator();
  while (iterator.hasNext()) {
    Forme f = iterator.next();
    if (f.isClicked(pMouse)) {
      iterator.remove();
    }
  }
}

void handleMove(Point pMouse) {
  if (!moveEnCours) {
    Forme cible = null;
    for (Forme f : listeFormes) {
      if (f.isClicked(pMouse)) {
        cible = f;
        break;
      }
    }
    if (cible != null) {
      formeSelectionnee = cible;
      moveEnCours = true;
    }
  } else {
    if (formeSelectionnee != null) {
      formeSelectionnee.setLocation(pMouse);
    }
    moveEnCours = false;
    formeSelectionnee = null;
    copieEnCours = false;
    formeCopie = null;
  }
}

void handleModify(Point pMouse) {
  Iterator<Forme> iterator = listeFormes.iterator();
  int index = 0;
  while (iterator.hasNext()) {
    Forme f = iterator.next();
    if (f.isClicked(pMouse)) {
      if (commande.getCouleur() == null || commande.getCouleur().equals("none")) {
        commande.setCouleur(commande.convertColor(f.getColor()));
      }

      if (commande.getForme() == null || commande.getForme().equals("none")) {
        Forme cible = f;
        Commande tmp = new Commande(null, null, commande.getCouleur(), null);
        color newColor;
        switch (commande.getCouleur()) {
          case "RED":    newColor = color(255,0,0); break;
          case "ORANGE": newColor = color(255,165,0); break;
          case "YELLOW": newColor = color(255,255,0); break;
          case "GREEN":  newColor = color(0,255,0); break;
          case "BLUE":   newColor = color(0,0,255); break;
          case "PURPLE": newColor = color(255,0,255); break;
          case "PINK":   newColor = color(255,102,178); break;
          case "DARK":
          default:       newColor = color(0,0,0); break;
        }
        cible.setColor(newColor);
        listeFormes.set(index, cible);
      } else {
        if (commande.getForme() == null) {
          if (f instanceof Cercle) {
            commande.setForme("CIRCLE");
          } else if (f instanceof Losange) {
            commande.setForme("DIAMOND");
          } else if (f instanceof Rectangle) {
            commande.setForme("RECTANGLE");
          } else if (f instanceof Triangle) {
            commande.setForme("TRIANGLE");
          }
        }
        listeFormes.set(index,
          commande.commandToForme(f.getLocation().x, f.getLocation().y));
      }
    }
    index++;
  }
}


void handleCopy(Point pMouse) {
  if (!copieEnCours) {
    Forme cible = null;
    for (Forme f : listeFormes) {
      if (f.isClicked(pMouse)) {
        cible = f;
        break;
      }
    }
    if (cible != null) {
      Commande cmdRef = new Commande("CREATE", null, null, null);
      cmdRef.setCouleur(cmdRef.convertColor(cible.getColor()));

      if (cible instanceof Cercle) {
        cmdRef.setForme("CIRCLE");
      } else if (cible instanceof Losange) {
        cmdRef.setForme("DIAMOND");
      } else if (cible instanceof Rectangle) {
        cmdRef.setForme("RECTANGLE");
      } else if (cible instanceof Triangle) {
        cmdRef.setForme("TRIANGLE");
      }

      formeCopie = cmdRef.commandToForme(pMouse.x, pMouse.y);
      if (formeCopie != null) {
        listeFormes.add(formeCopie);
        formeSelectionnee = formeCopie;
        moveEnCours = true;
        copieEnCours = true;
      }
    }
  }
}
