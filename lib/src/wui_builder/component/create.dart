part of component;

Node createComponentNode(
    Component vnode, List<ComponentDidMount> pendingComponentDidMounts) {
  // register the beforeAnimationFrameCallback if it is set
  if (vnode.beforeAnimationFrame != null)
    addBeforeAnimationFrameCallback(vnode);

  // lifecycle - set the initial state for the component
  vnode._state = vnode.getInitialState();

  // lifecycle - componentWillMount
  vnode.componentWillMount();

  // build the new virtual tree
  final child = vnode.render();

  if (!child.vif) return null; // TODO: still call cdm?

  vnode._child = child;

  // set the parent of the render result to this node
  vnode.child.parent = vnode;

  // create a dom node for the render result
  final domNode = createNode(vnode.child, pendingComponentDidMounts);

  // lifecycle - componentDidMount
  pendingComponentDidMounts.add(vnode.componentDidMount);

  // return the newly created dom node for this component
  return domNode;
}
