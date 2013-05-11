class @CustomInputs


  @initialize: =>
    @checkBox = ".checkbox"
    @checkBoxInput = @checkBox + " input[type='checkbox']"
    @checkBoxChecked = "checked"
    @checkBoxDisabled = "disabled"
    @radio = ".radio"
    @radioInput = @radio + " input[type='radio']"
    @radioOn = "checked"
    @radioDisabled = "disabled"

    $(@checkBox).each (index, element) =>
      $(element).prepend("<span class='checkbox-icon-outer'><span class='checkbox-icon-inner'></span></span>")

    $(@radio).each (index, element) =>
      $(element).prepend("<span class='radio-icon-outer'><span class='radio-icon-inner'></span></span>")

    $(@checkBox).click (index, element) =>
      @setupLabel()

    $(@radio).click (index, element) =>
      @setupLabel()

    @setupLabel()

  @setupLabel: =>
    if $(@checkBoxInput).length
      $(@checkBox).each (index, element) =>
        $(element).removeClass(@checkBoxChecked)

      $(@checkBoxInput + ":checked").each (index, element) =>
        $(element).parent(@checkBox).addClass(@checkBoxChecked)

      $(@checkBoxInput + ":disabled").each (index, element) =>
        $(element).parent(@checkBox).addClass(@checkBoxDisabled)

    if $(@radioInput).length
      $(@radio).each (index, element) =>
        $(element).removeClass(@radioOn)

      $(@radioInput + ":checked").each (index, element) =>
        $(element).parent(@radio).addClass(@radioOn)

      $(@radioInput + ":disabled").each (index, element) =>
        $(element).parent(@radio).addClass(@radioDisabled)
