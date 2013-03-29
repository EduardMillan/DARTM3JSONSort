import 'dart:html';
import 'dart:uri';
import 'dart:json' as json;

/******
 * Cadena JSON con los datos de los enlaces:
 * "Sección": {
 *  "Subsección":
 *    { "Texto del enlace":
 *      { "url": "url", "comment": "comentario" }
 *    }
 * } 
******/

String BookmarksList = '''{
      "Open Source": {
        "General":
          { "The Architecture of Open Source Applications":
              { "url": "http://www.aosabook.org/en/index.html", "comment": "" }
          }
      },
      "Brainstorming": {
        "General":
          { "TED":
              { "url": "http://www.ted.com", "comment": "Technology, Entertainment, Design" }
          }
      },
      "Programación": {
        "Recursos":
          { "Stack Overflow": 
              { "url": "http://stackoverflow.com/", "comment": "Quizás el mejor foro sobre programación" },
            "Wotsit":
              { "url": "http://www.wotsit.org/", "comment": "Recursos para programadores" }
          },
        "General":
          { "Coding Horror":
              { "url": "http://www.codinghorror.com/blog/", "comment": "" }
          }
      },
      "Proyectos": {
        "General":
          { "Project Euler":
              { "url": "http://projecteuler.net/", "comment": "Desafíos matemáticos y de computación" }
          }
      }
    }
''';

/******
 * Clases para generar los divs de cada sección.
******/

class Seccion
{
  Element div;
  
  Seccion(String nombre)
  {
    this.div = new Element.tag('div');
    this.div.classes.add('cSeccion');
    this.div.innerHtml = nombre;
  }
}

class SubSeccion
{
  Element div;
  
  SubSeccion(String nombre)
  {
    this.div = new Element.tag('div');
    this.div.classes.add('cSubSeccion');
    this.div.innerHtml = nombre;
  }
}

class MargenInferior
{
  Element div;
  
  MargenInferior()
  {
    this.div = new Element.tag('div');
    this.div.classes.add('cMargen');
  }
  
}

class Link
{
  Element div;
  
  Link(String texto, Map data)
  {
    this.div = fDivContainer(texto, data);
  }
  
  Element fDivContainer(String texto, Map data)
  {
    Element eDiv = new Element.tag('div');
    eDiv.classes.add('cContainer');
    eDiv.children.add(fDivLink(texto, data));
    eDiv.children.add(fDivComment(data['comment']));
    return eDiv;
  }
  
  Element fDivLink(String texto, Map data)
  {
    Element eDiv = new Element.tag('div');
    eDiv.classes.add('cLink');
    eDiv.classes.add('tabLink');
    eDiv.children.add(fImage(data['url']));
    eDiv.children.add(fAHRef(data['url'], texto));
    return eDiv;
  }
  
  Element fDivComment(String comment)
  {
    Element eDiv = new Element.tag('div');
    eDiv.classes.add('cComment');
    eDiv.innerHtml = comment;
    return eDiv;
  }
  
  Element fAHRef(String url, String txt)
  {
    AnchorElement eAHRef = new AnchorElement();
    eAHRef.classes.add('cHRef');
    eAHRef.href = url;
    eAHRef.text = txt;
    eAHRef.target = '_blank';
    return eAHRef;
  }
  
  Element fImage(String url)
  {
    Uri src = new Uri(url);
    
    ImageElement image = new ImageElement();
    image.classes.add('cImage');
    image.src = 'http://'.concat(src.domain).concat('/favicon.ico');
    Element imageLink = fAHRef(url, '');
    imageLink.children.add(image);
    return imageLink;
  }
}

/*****
 * Se ordena un Map convirtiéndolo primero a string junto con su valor y almacenándolo en un array de strings (Lista).
 * Para convertirlo en string se usa json.stringify para conservar las comillas dobles de los campos, asimismo se añaden los dos puntos (:) que también se perderían
 * Se crea una tira con el nombre del campo concatenado con su valor para mantenerlos apareados cuando se ordenen por el nombre del campo.
 * Se devuelve un objeto JSON con los campos ordenados. Antes se prepara la cadena a convertir quitándole el primer y último carácter (corchetes [], formato lista) y se
 * sustituyen por llaves ({}, formato JSON). 
******/

Map OrdenaJSON(Map data)
{
  var Lista = <String>[];
  
  data.forEach((k, v) { Lista.add(json.stringify(k).concat(':').concat(json.stringify(v))); });
  Lista.sort((a, b) => a.compareTo(b));
  String s = Lista.toString().substring(1, Lista.toString().length - 1);
  return json.parse('{'.concat(s).concat('}'));
}

/*****
 * Se crea un bucle para cada categoría de la cadena JSON: Sección, Subsección y Texto del link. Para cada categoría se llama al procedimiento de ordenación. 
******/

Map OrdenaBookmarks(String data)
{
  Map Lista = OrdenaJSON(json.parse(data));
  Lista.forEach((kSeccion, v)
      {
        Lista[kSeccion] = OrdenaJSON(Lista[kSeccion]);
        Lista[kSeccion].forEach((kSubSeccion, v)
            {
                Lista[kSeccion][kSubSeccion] = OrdenaJSON(Lista[kSeccion][kSubSeccion]);
            });
      });
  return Lista;
}

void ProcesaBookmarks(Lista)
{
  Map JSONBookmarks = OrdenaBookmarks(Lista);
  Seccion sRef;
  SubSeccion sbRef;
  Link lRef;
  MargenInferior sMI;
  Element container = query('#BLContainer');
  JSONBookmarks.forEach((kSeccion, v) 
      {
        sRef = new Seccion(kSeccion);
        container.children.add(sRef.div);
        JSONBookmarks[kSeccion].forEach((kSubSeccion, v)
            {
              sbRef = new SubSeccion(kSubSeccion);
              container.children.add(sbRef.div);
              JSONBookmarks[kSeccion][kSubSeccion].forEach((kTxtLink, v)
                  {
                    lRef = new Link(kTxtLink, v);
                    container.children.add(lRef.div);
                  });
                  sMI = new MargenInferior();
                  container.children.add(sMI.div);
            });
      });        
  
}

void main()
{
  ProcesaBookmarks(BookmarksList);
}

