function parseScripts(node) {

  function nodeScriptIs(node) {
    return node.tagName === 'SCRIPT';
  }

  function nodeScriptClone(node){
    let script  = document.createElement('script');
    script.text = node.innerHTML;
    Array.prototype.forEach.call(node.attributes, (attr)=>{
      script.setAttribute(attr.name, attr.value);
    });
    return script;
  }

  function nodeScriptReplace(node) {
    if ( nodeScriptIs(node) === true ) {
      node.parentNode.replaceChild( nodeScriptClone(node) , node );
    }
    else {
      Array.prototype.forEach.call(node.childNodes, (childNode) => nodeScriptReplace(childNode));
    }

    return node;
  }

  return nodeScriptReplace(node);
}

function injectHTML(node, content) {
  if (content instanceof Node) {
    node.appendChild(content);
  }
  else {
    node.innerHTML = content;
  }
  parseScripts(node);
}

module.exports = injectHTML;
