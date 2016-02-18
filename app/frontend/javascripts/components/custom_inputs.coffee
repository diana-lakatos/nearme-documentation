module.exports = class CustomInputs

  @initialize: (context = 'body') =>
    @context = $(context)
    @checkBox = ".checkbox"
    @checkBoxInput = @checkBox + " input[type='checkbox']"
    @checkBoxChecked = "checked"
    @checkBoxDisabled = "disabled"
    @radio = ".radio"
    @radioInput = @radio + " input[type='radio']"
    @radioOn = "checked"
    @radioDisabled = "disabled"

    @context.find(@checkBox).each (index, element) =>
      try
        $(element).prepend("<span class='checkbox-icon-outer'><span class='checkbox-icon-inner'></span></span>")
      catch error

    @context.find(@radio).each (index, element) =>
      $(element).prepend("<span class='radio-icon-outer'><span class='radio-icon-inner'></span></span>")

    @context.find(@checkBox).change (index, element) =>
      @setupLabel()

    @context.find(@radio).change (index, element) =>
      @setupLabel()

    @setupLabel()

  @setupLabel: =>
    if @context.find(@checkBoxInput).length
      @context.find(@checkBox).each (index, element) =>
        $(element).removeClass(@checkBoxChecked)

      @context.find(@checkBoxInput + ":checked").each (index, element) =>
        $(element).parents(@checkBox).addClass(@checkBoxChecked)

      @context.find(@checkBoxInput + ":disabled").each (index, element) =>
        $(element).parents(@checkBox).addClass(@checkBoxDisabled)

    if @context.find(@radioInput).length
      @context.find(@radio).each (index, element) =>
        $(element).removeClass(@radioOn)

      @context.find(@radioInput + ":checked").each (index, element) =>
        $(element).parents(@radio).addClass(@radioOn)

      @context.find(@radioInput + ":disabled").each (index, element) =>
        $(element).parents(@radio).addClass(@radioDisabled)
