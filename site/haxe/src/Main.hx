package ;

import org.aswing.geom.IntPoint;
import jive.Navigation;
import viewmodel.MainViewModel;
import org.aswing.border.EmptyBorder;
import org.aswing.Insets;
import org.aswing.SolidBackground;
import flash.events.Event;
import jive.plaf.flat.FlatLookAndFeel;
import org.aswing.UIManager;
import flash.display.Sprite;
import flash.Lib; 
import org.aswing.AsWingManager;

import view.MainView;

class Main extends Sprite {
    public function new() {
        super();
        AsWingManager.initAsStandard(Lib.current);
        UIManager.setLookAndFeel(new FlatLookAndFeel());

        var mainView: MainView = new MainView();
        var mainVM = new MainViewModel();
        mainView.dataContext = mainVM;

        Navigation.instance.addRoute("/", function(after) { mainVM.openAbout.action(); });
        Navigation.instance.addRoute("/demo", function(after) { mainVM.openDemo.action(); });

        Navigation.instance.navigate([mainView.menuBar.getMenu(1)]);

        mainView.setBackgroundDecorator(new SolidBackground(UIManager.getColor("window")));
        mainView.setBorder(new EmptyBorder(null, Insets.createIdentic(10)));

        var resize = function() {
            var w = Lib.current.stage.stageWidth;
            var h = Lib.current.stage.stageHeight;
            mainView.setSizeWH(if (w <= 1200) w else 1200, h);
            mainView.location = new IntPoint(if (w <= 1200) 0 else Std.int((w - 1200)/2), 0);
        }

        resize();

        Lib.current.stage.addEventListener(Event.RESIZE, function(e) { resize(); });

        mainView.show();
   }
}
