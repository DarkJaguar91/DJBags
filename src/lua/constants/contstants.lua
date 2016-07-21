local NAME, ADDON = ...

--region Types

DJBags_TYPE_CONTAINER = 'container'
DJBags_TYPE_ITEM_CONTAINER = 'itemContainer'
DJBags_TYPE_SUB_CLASS = 'djbags_sub_classes'

DJBags_FORMATTER_MASONRY = 'Massonry'
DJBags_FORMATTER_BOX = 'Box'

--endregion

--region Settings

DJBags_SETTING_BACKGROUND_COLOR = 'djbags_background_color'
DJBags_SETTING_BORDER_COLOR = 'djbags_border_color'
DJBags_SETTING_TEXT_COLOR = 'djbags_text_color'
DJBags_SETTING_PADDING = 'djbags_padding'
DJBags_SETTING_SPACING = 'djbags_spacing'
DJBags_SETTING_SCALE = 'djbags_scale'
DJBags_SETTING_FORMATTER = 'djbags_formatter'
DJBags_SETTING_FORMATTER_VERT = 'djbags_formatter_vert'
DJBags_SETTING_FORMATTER_MAX_ITEMS = 'djbags_formatter_max_items'
DJBags_SETTING_FORMATTER_MAX_HEIGHT = 'djbags_formatter_max_height'
DJBags_SETTING_FORMATTER_BOX_COLS = 'djbags_formatter_box_cols'
DJBags_SETTING_TRUNCATE_SUB_CLASS = 'djbags_truncate_sub_class'
DJBags_SETTING_TEXT_SIZE = 'djbags_truncate_text_size'

--endregion

--region Locale

local localeText= {}
localeText['enUS'] = function()
    DJBags_LOCALE_ITEM_CONTAINER_SETTINGS = 'Item Container Settings:'
    DJBags_LOCALE_CONTAINER_SETTINGS = 'Category Container Settings:'
    DJBags_LOCALE_SUB_CLASS_SETTINGS = 'Sub Class Settings:'
    DJBags_LOCALE_SETTINGS = 'DJBags Settings:'
    DJBags_LOCALE_CLEAR_NEW_ITEMS = 'Clear new items'
    DJBags_LOCALE_BACKGROUND_COLOR = 'Background color'
    DJBags_LOCALE_BORDER_COLOR = 'Border color'
    DJBags_LOCALE_TEXT_COLOR = 'Text color'
    DJBags_LOCALE_PADDING = 'Padding'
    DJBags_LOCALE_SPACING = 'Spacing'
    DJBags_LOCALE_SCALE = 'Scale'
    DJBags_LOCALE_TEXT_SIZE = 'Text size'
    DJBags_LOCALE_MASONRY = 'Massonry'
    DJBags_LOCALE_BOX = 'Box'
end

if localeText[GetLocale()] then
    localeText[GetLocale()]()
else
    localeText['enUS']()
end

--endregion