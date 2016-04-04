/*
 Copyright aswing.org, see the LICENCE.txt.
*/

package org.aswing;

import org.aswing.plaf.basic.BasicToggleButtonUI;
	

/**
 * An implementation of a two-state button.  
 * The <code>JRadioButton</code> and <code>JCheckBox</code> classes
 * are subclasses of this class.
 * @author paling
 */
class JToggleButton extends AbstractButton
{
	public function new(text:String="", icon:Icon=null)
	{
		super(text, icon);
		setClipMasked(true);
		setName("JToggleButton");
    	setModel(new ToggleButtonModel());
		
		//updateUI();
	}
	
    @:dox(hide)
    override public function updateUI():Void{
    	setUI(UIManager.getUI(this));
    }

    @:dox(hide)
    override public function getDefaultBasicUIClass():Class<Dynamic>{
    	return org.aswing.plaf.basic.BasicToggleButtonUI;
    }

    @:dox(hide)
	override public function getUIClassID():String{
		return "ToggleButtonUI";
	}

    override private function calculateTargetBackgroundTransitionFactor(): Float {
        return
            if (model.isPressed() || model.isSelected()) -1.0
            else if (model.isRollOver()) 1.0
            else 0.0;
    }

	
}