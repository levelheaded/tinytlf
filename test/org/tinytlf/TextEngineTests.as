package org.tinytlf
{

    import flash.display.Stage;

    import flash.events.Event;

    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import mockolate.*;

    import mx.core.UIComponent;

    import org.flexunit.Assert;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.tinytlf.decor.ITextDecor;
    import org.tinytlf.decor.TextDecor;
    import org.tinytlf.interaction.ITextInteractor;
    import org.tinytlf.interaction.TextInteractorBase;
    import org.tinytlf.layout.ITextLayout;
    import org.tinytlf.layout.TextLayoutBase;
    import org.tinytlf.layout.factory.AbstractLayoutModelFactory;
    import org.tinytlf.layout.factory.ILayoutModelFactory;
    import org.tinytlf.styles.ITextStyler;
    import org.tinytlf.styles.TextStyler;

    public class TextEngineTests
    {
        private var engineStage:Stage;
        private var engine:TextEngine;
        private var delayTimer:Timer;

        [Before(async, timeout=5000)]
        public function setup():void
        {
            engineStage = UIImpersonator.addChild(new UIComponent()).stage;
            engine = new TextEngine(engineStage);
            delayTimer = new Timer(100, 1);
            Async.proceedOnEvent(this,
                    prepare(ITextDecor,ILayoutModelFactory, ITextLayout),
                    Event.COMPLETE);
        }

        [After]
        public function tearDown():void
        {
            engineStage = null;
            engine = null;
            delayTimer = null;
        }

        [Test]
        public function text_engine_constructed():void
        {
            Assert.assertTrue(engine != null);
        }

        //--------------------------------------------------------------------------
        //
        //  default properties tests
        //
        //--------------------------------------------------------------------------

        [Test]
        public function engine_has_default_decor():void
        {
            var decor:ITextDecor = engine.decor;

            Assert.assertTrue(decor is TextDecor);
        }

        [Test]
        public function engine_has_default_block_factory():void
        {
            var factory:ILayoutModelFactory = engine.blockFactory;

            Assert.assertTrue(factory is AbstractLayoutModelFactory);
        }

        [Test]
        public function engine_has_default_interactor():void
        {
            var interactor:ITextInteractor = engine.interactor;

            Assert.assertTrue(interactor is TextInteractorBase);
        }

        [Test]
        public function engine_has_default_layout():void
        {
            var layout:ITextLayout = engine.layout;

            Assert.assertTrue(layout is TextLayoutBase);
        }

        [Test]
        public function engine_has_default_styler():void
        {
            var styler:ITextStyler = engine.styler;

            Assert.assertTrue(styler is TextStyler)
        }

        //--------------------------------------------------------------------------
        //
        //  public method tests
        //
        //--------------------------------------------------------------------------

        //----------------------------------------------------
        //  prerender
        //----------------------------------------------------

        [Test]
        public function test_prerender_calls_decor_remove_all():void
        {
            var decor:ITextDecor = strict(ITextDecor);
            stub(decor).method("removeAll");
            stub(decor).setter("engine");

            engine.decor = decor;
            engine.prerender();

            verify(decor).method("removeAll").once();
        }

        [Test]
        public function prerender_calls_block_factory_create_blocks():void
        {
            var blockFactory:ILayoutModelFactory = nice(ILayoutModelFactory);
            stub(blockFactory).method("createBlocks");

            engine.blockFactory = blockFactory;
            engine.prerender();

            verify(blockFactory).method("createBlocks").once();
        }

        //----------------------------------------------------
        //  invalidation triggers rendering
        //----------------------------------------------------
        
        [Test(async)]
        public function invalidate_calls_clear_on_layout_after_current_frame():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("clear");

            engine.layout = layout;
            engine.invalidate();

            Async.handleEvent(this, delayTimer, TimerEvent.TIMER_COMPLETE,
                    handleInvalidateCallsClearOnLayoutAfterCurrentFrame, 500, layout);

            delayTimer.start();
        }

        private function handleInvalidateCallsClearOnLayoutAfterCurrentFrame(event:Event, layout:ITextLayout):void
        {
            verify(layout).method("clear").once();
        }

        [Test(async)]
        public function invalidate_calls_render_on_layout_after_current_frame():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("render");

            engine.layout = layout;
            engine.invalidate();

            Async.handleEvent(this, delayTimer, TimerEvent.TIMER_COMPLETE,
                    handleInvalidateCallsRenderOnLayoutAfterCurrentFrame, 500, layout);

            delayTimer.start();
        }

        private function handleInvalidateCallsRenderOnLayoutAfterCurrentFrame(event:Event, layout:ITextLayout):void
        {
            verify(layout).method("render").once();
        }

        [Test(async)]
        public function invalidate_calls_render_on_decor_after_current_frame():void
        {
            var decor:ITextDecor = nice(ITextDecor);
            stub(decor).method("render");

            engine.decor = decor;
            engine.invalidate();

            Async.handleEvent(this, delayTimer, TimerEvent.TIMER_COMPLETE,
                    handleInvalidateCallsRenderOnDecorAfterCurrentFrame, 500, decor);

            delayTimer.start();
        }

        private function handleInvalidateCallsRenderOnDecorAfterCurrentFrame(event:Event, decor:ITextDecor):void
        {
            verify(decor).method("render").once();
        }

        [Test(async)]
        public function invalidate_calls_resetShapes_on_layout_after_current_frame():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("resetShapes");

            engine.layout = layout;
            engine.invalidate();

            Async.handleEvent(this, delayTimer, TimerEvent.TIMER_COMPLETE,
                    handleInvalidateCallsResetShapesOnLayoutAfterCurrentFrame, 500, layout);

            delayTimer.start();
        }

        private function handleInvalidateCallsResetShapesOnLayoutAfterCurrentFrame(event:Event, layout:ITextLayout):void
        {
            verify(layout).method("resetShapes").once();
        }

        //----------------------------------------------------
        //  rendering
        //----------------------------------------------------

        [Test]
        public function render_lines_renders_layout():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("render");

            engine.layout = layout;
            engine.renderLines();

            verify(layout).method("render").once();
        }

        [Test]
        public function render_lines_clears_layout():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("clear");

            engine.layout = layout;
            engine.renderLines();

            verify(layout).method("clear").once();
        }

        [Test]
        public function render_decorations_resets_shapes_in_layout():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("resetShapes");

            engine.layout = layout;
            engine.renderDecorations();

            verify(layout).method("resetShapes").once();
        }

        [Test]
        public function render_decorations_renders_decor():void
        {
            var decor:ITextDecor = nice(ITextDecor);
            stub(decor).method("render");

            engine.decor = decor;
            engine.renderDecorations();

            verify(decor).method("render").once();
        }
    }
}
