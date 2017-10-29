part of wui_builder;

void _updateNode(Element parent, Element node, VNode newVNode, VNode oldVNode) {
  if (oldVNode == null) {
    // if the old vnode is null create a new element and append it to the dom
    parent.append(_createNode(newVNode));
  } else if (newVNode == null) {
    // if the new vnode is null dispose of it and remove it from the dom
    _disposeVNode(oldVNode);
    node.remove();
  } else if (newVNode.runtimeType != oldVNode.runtimeType) {
    // if the new vnode is a different type, dispose the old and replace it with a new one
    _disposeVNode(oldVNode);
    node = _createNode(newVNode);
  } else if (newVNode is VElement) {
    _updateElementNode(parent, node, newVNode, oldVNode);
  } else if (newVNode is Component) {
    _updateComponentNode(parent, node, newVNode, oldVNode);
  }
}

void _updateElementNode(
    Element parent, Element node, VElement newVNode, VElement oldVNode) {
  // update attributes that have changed
  newVNode._updateElementAttributes(oldVNode, node);

  // if shouldUpdateSubs is set update subscriptions
  if (newVNode.shouldUpdateSubs)
    newVNode._updateEventListenersToElement(oldVNode, node);

  // update each child element
  final newLength = newVNode._childrenSet ? newVNode._children.length : 0;
  final oldLength = oldVNode._childrenSet ? oldVNode._children.length : 0;
  var child = node.children.isEmpty ? null : node.children.first;
  for (var i = 0; i < newLength || i < oldLength; i++) {
    _updateNode(
      node,
      child,
      i < newLength ? newVNode._children.elementAt(i) : null,
      i < oldLength ? oldVNode._children.elementAt(i) : null,
    );
    child = child != null ? child.nextNode : null;
  }
}

void _updateComponentNode(
    Element parent, Element node, Component newVNode, Component oldVNode) {
  // copy the state of the last node to the newly created node
  newVNode._state = oldVNode._state;

  // if the should component update fails do not proceed
  if (!newVNode.shouldComponentUpdate(
      oldVNode._props, newVNode._props, oldVNode._state, newVNode._state))
    return;

  // lifecycle - componentWillUpdate
  newVNode.componentWillUpdate(
      oldVNode._props, newVNode._props, oldVNode._state, newVNode._state);

  // build the new virtual tree
  newVNode._render(newVNode._props, newVNode._state);

  // call update node for the new virtual tree
  _updateNode(parent, node, newVNode._renderResult, oldVNode._renderResult);

  // lifecycle - componentDidUpdate
  newVNode.componentDidUpdate(
      oldVNode._props, newVNode._props, oldVNode._state, newVNode._state);
}

// calls the necessary methods to clean up a vnode
void _disposeVNode(VNode node) {
  if (node is Component)
    node.componentWillUnmount(node._props, node._state);
  else
    (node as VElement).dispose();
}