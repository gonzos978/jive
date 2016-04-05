package jive.hml;

#if macro
import lime.project.MetaData;
import haxe.rtti.CType.MetaData;
import hml.xml.writer.DefaultNodeWriter;
import hml.xml.writer.IHaxeWriter;
import hml.xml.adapters.base.MergedAdapter;

import hml.base.MatchLevel;
import hml.xml.Data;

import hml.xml.adapters.FlashAdapter;
import hml.xml.adapters.base.BaseMetaAdapter;

import haxe.macro.Expr;

using haxe.macro.Context;
using haxe.macro.Tools;

using StringTools;
using Lambda;
#end

#if macro
class JiveAdapter extends MergedAdapter<XMLData, Node, Type> {
	public function new() {
		super([
			new ContainerAdapter(),
			new ComponentAdapter(),
			new DisplayObjectAdapter(),
			new IEventDispatcherAdapter(),
			new JiveXMLAdapter(),
            new BaseCommandAdapter()
		]);
	}

	static public function register():Void {
		hml.Hml.registerProcessor(new hml.xml.XMLProcessor([new JiveAdapter()]));
	}
}

class ComponentAdapter extends DisplayObjectAdapter {
    public function new(?baseType:ComplexType, ?events:Map<String, MetaData>, ?matchLevel:MatchLevel) {
		if (baseType == null) baseType = macro : jive.Component;
		if (matchLevel == null) matchLevel = CustomLevel(ClassLevel, 20);
		super(baseType, events, matchLevel);
    }

    override public function getNodeWriters():Array<IHaxeNodeWriter<Node>> {
		return [new ComponentWithMetaWriter(baseType, metaWriter, matchLevel)];
	}
}

class ComponentWithMetaWriter extends BaseNodeWithMetaWriter {
	override function writeNodes(node:Node, scope:String, writer:IHaxeWriter<Node>, method:Array<String>) {
		var nodesToRemove = [];
		for (n in node.nodes) {
			if (n.cData != null && n.cData.indexOf('{Binding') >= 0) {
				nodesToRemove.push(n);

				var mode = 'oneway'; //once, oneway, twoway

                var trimmed = n.cData.replace('{Binding','').replace('}','').trim();
				var sourcePropertyName = trimmed;

				// set mode
				if (trimmed.indexOf(" ") >= 0) {
                    var splitted = trimmed.split(" ");
                    sourcePropertyName = splitted[0];
                    if (splitted[1].startsWith("mode=")) {
                    	var m = splitted[1].split("=");
                    	mode = m[1];
                    }
				}

				var valueSource = 'this.dataContext.' + sourcePropertyName;
				var propertyName = scope + "." + n.name.name;

                method.push('{');

				method.push('if (null != dataContext) { $propertyName = $valueSource; }');

				if (mode.indexOf("way") > 0) {
					method.push('var programmaticalyChange = false;');

					method.push('var sourcePropertyListener = function(_,_) {
						if (!programmaticalyChange) {
							programmaticalyChange = true;
							$propertyName = $valueSource;
							programmaticalyChange = false;
						}
					};');
					method.push('var bindSourceListener = function() { bindx.Bind.bind($valueSource, sourcePropertyListener); }');
					method.push('if (null != dataContext) { bindSourceListener(); }');
					method.push('bindx.Bind.bind(this.dataContext, function(old,_) {
							if (null != old) { bindx.Bind.unbind(old.$sourcePropertyName, sourcePropertyListener);}
							if (null != this.dataContext) {
								$propertyName = $valueSource;
								bindSourceListener();
							}
						});
					');

					if (mode == "twoway") {
						method.push('var propertyListener = function(_,_) {
							if (!programmaticalyChange && null != this.dataContext) {
								programmaticalyChange = true;
								$valueSource = $propertyName;
								programmaticalyChange = false;
							}
						};');
						method.push('bindx.Bind.bind($propertyName, propertyListener);');
						method.push('bindx.Bind.bind(this.dataContext, function(old,_) {
						 	if (null != this.dataContext) {
								$valueSource = $propertyName;
							}
						});');
					}
				}

                method.push('}');
            }
		}
		for (n in nodesToRemove) {
			node.nodes.remove(n);
		}
		super.writeNodes(node, scope, writer, method);
	}
}

class ContainerAdapter extends ComponentAdapter {
    public function new(?baseType:ComplexType, ?events:Map<String, MetaData>, ?matchLevel:MatchLevel) {
		if (baseType == null) baseType = macro : jive.Container;
		if (matchLevel == null) matchLevel = CustomLevel(ClassLevel, 30);
		super(baseType, events, matchLevel);

    }
    override public function getNodeWriters():Array<IHaxeNodeWriter<Node>> {
		return [new ContainerWithMetaWriter(baseType, metaWriter, matchLevel)];
	}
}

class ContainerWithMetaWriter extends ComponentWithMetaWriter {
	override function child(node:Node, scope:String, child:Node, method:Array<String>, assign = false):Void {
		var t = child.superType;
		if (t.indexOf("Popup") >= 0 || t.indexOf("Window") >= 0 || t.indexOf("Frame") >= 0 || t.indexOf("Dialog") >= 0) {
            method.push('${universalGet(child)}.owner = null;');
        } else if (assign){
            method.push('$scope = ${universalGet(child)};');
        } else {
            method.push('$scope.append(${universalGet(child)});');
        }
	}
}

class BaseCommandAdapter extends ComponentAdapter {
    public function new(?baseType:ComplexType, ?events:Map<String, MetaData>, ?matchLevel:MatchLevel) {
        if (baseType == null) baseType = macro : jive.BaseCommand;
        if (matchLevel == null) matchLevel = CustomLevel(ClassLevel, 10);
        super(baseType, events, matchLevel);

    }
}
#end