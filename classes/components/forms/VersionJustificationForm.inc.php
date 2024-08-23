<?php

use PKP\components\forms\FormComponent;
use PKP\components\forms\FieldText;
use PKP\components\forms\FieldOptions;

define('FORM_VERSION_JUSTIFICATION', 'versionJustification');

class VersionJustificationForm extends FormComponent
{
    public function __construct($action, $submission)
    {
        $this->action = $action;
        $this->id = FORM_VERSION_JUSTIFICATION;
        $this->method = 'POST';

        $publication = $submission->getLatestPublication();

        $this->addField(new FieldText('versionJustification', [
            'label' => __('plugins.generic.authorVersion.lastVersionJustification'),
            'value' => $publication->getData('versionJustification'),
            'size' => 'large',
        ]));

        $this->addField(new FieldOptions('versionType', [
            'label' => __('plugins.generic.authorVersion.versionType'),
            'type' => 'radio',
            'options' => [
                ['value' => 'update', 'label' => __('plugins.generic.authorVersion.versionTypeUpdate')],
                ['value' => 'revision', 'label' => __('plugins.generic.authorVersion.versionTypeRevision')],
                ['value' => 'correction', 'label' => __('plugins.generic.authorVersion.versionTypeCorrection')],               
            ],
            'value' => $publication->getData('versionType'),
        ]));   
    }
}
