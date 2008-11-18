# Add methods from NiftyCall to ActionView::Base for use in views. Really,  the only
# method that you will be concerned with is the +display_calendar+ method.
ActionView::Base.send(:include, NiftyCal)