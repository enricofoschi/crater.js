class @Helpers.Client.Modal

    MODAL_CONTENT = '<div class="modal fade" id="invitation-action-modal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close btn-close close-modal"><span>&times;</span></button>
                    <h4 class="modal-title"></h4>
                </div>
                <div class="modal-body">
                </div>
                <div class="modal-footer">
                    <a class="btn-cancel"></a>
                    <a class="btn-cta"></a>
                </div>
            </div>
        </div>
    </div>'

    $modal = null
    $modalBody = null
    $modalHeader = null
    $modalTitle = null
    $modalPrimaryCta = null
    $modalPrimaryCancel = null

    @Init: =>
        if not $modal
            $modal = $ MODAL_CONTENT
            $modalBody = $modal.find '.modal-body:first'
            $modalHeader = $modal.find '.modal-header:first'
            $modalTitle = $modal.find '.modal-title:first'
            $modalPrimaryCta = $modal.find '.btn-cta'
            $modalPrimaryCancel = $modal.find '.btn-cancel'
            $(document.body).append $modal

    @Show: (options) =>
        @Init()

        if not options.title
            $modalHeader.hide()
        else
            $modalHeader.show()
            $modalTitle.text options.title

        $modalBody.html options.container.html()
        $modalPrimaryCta.text(options.ctaCopy || translate('commons.submit')).attr('class', (options.primaryBtnClass || 'btn btn-success') +  (if options.keepOpen then '' else ' btn-close'))
        $modalPrimaryCancel.text(options.cancelCopy || translate('commons.cancel')).attr('class', (options.cancelBtnClass || 'text-danger') + ' btn-close')

        $modalPrimaryCta.unbind('click').bind('click', options.callback)
        $modal.find('.btn-close').unbind('click').click @Close

        $modalPrimaryCancel.unbind('click').bind('click', ->
            options.cancelCallback $modalBody

        ) if options.cancelCallback

        $modalPrimaryCta.click(->
            options.ctaCallback $modalBody
        ) if options.ctaCallback

        $modal.modal {
            show: true
            backdrop: 'static'
            keyboard: true
        }

        if options.onRendered
            options.onRendered $modalBody

    @ShowOwn: ($ownModal) =>

        $ownModal.modal({
            show: true
            backdrop: 'static'
            keyboard: true
        })

        $ownModal.find('.btn-close').unbind('click').bind('click', ->
            $ownModal.modal('hide')
        )

    @Close: ->
        $modal.modal('hide')