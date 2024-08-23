{**
 * templates/authorDashboard/authorDashboard.tpl
 *
 * Copyright (c) 2014-2020 Simon Fraser University
 * Copyright (c) 2003-2020 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * Display the author dashboard.
 *}
{strip}
	{assign var=primaryAuthor value=$submission->getPrimaryAuthor()}
	{if !$primaryAuthor}
		{assign var=authors value=$submission->getAuthors()}
		{assign var=primaryAuthor value=$authors[0]}
	{/if}
	{assign var=submissionTitleSafe value=$submission->getLocalizedTitle()|strip_unsafe_html}
	{if $primaryAuthor}
		{assign var="pageTitleTranslated" value=$primaryAuthor->getFullName()|concat:", ":$submissionTitleSafe}
	{else}
		{assign var="pageTitleTranslated" value=$submissionTitleSafe}
	{/if}
	{extends file="layouts/backend.tpl"}
{/strip}

{block name="page"}
	<div class="pkpWorkflow">
		<pkp-header class="pkpWorkflow__header">
			<h1 class="pkpWorkflow__identification">
				<badge
					v-if="submission.status === getConstant('STATUS_PUBLISHED')"
					class="pkpWorkflow__identificationStatus"
					:is-success="true"
				>
					{translate key="publication.status.published"}
				</badge>
				<badge
					v-else-if="submission.status === getConstant('STATUS_DECLINED')"
					class="pkpWorkflow__identificationStatus"
					:is-warnable="true"
				>
					{translate key="common.declined"}
				</badge>
				<span class="pkpWorkflow__identificationId">{{ submission.id }}</span>
				<span class="pkpWorkflow__identificationDivider">/</span>
				<span class="pkpWorkflow__identificationAuthor">
					{{ currentPublication.authorsStringShort }}
				</span>
				<span class="pkpWorkflow__identificationDivider">/</span>
				<span class="pkpWorkflow__identificationTitle">
					{{ localizeSubmission(currentPublication.title, currentPublication.locale) }}
				</span>
			</h1>
			<template slot="actions">
				<pkp-button
					v-if="uploadFileUrl"
					ref="uploadFileButton"
					@click="openFileUpload"
				>
					{translate key="common.upload.addFile"}
				</pkp-button>
				<pkp-button
					@click="openLibrary"
				>
					{translate key="editor.submissionLibrary"}
				</pkp-button>
			</template>
		</pkp-header>
		{include file="controllers/notification/inPlaceNotification.tpl" notificationId="authorDashboardNotification" requestOptions=$authorDashboardNotificationRequestOptions}
		<tabs :track-history="true">
			<tab id="publication" label="{translate key="submission.publication"}">
				<div class="pkpPublication" ref="publication" aria-live="polite">
					<pkp-header class="pkpPublication__header" :is-one-line="false">
						<span class="pkpPublication__status">
							<strong>{{ statusLabel }}</strong>
							<span v-if="workingPublication.status === getConstant('STATUS_PUBLISHED')" class="pkpPublication__statusPublished">{translate key="publication.status.published"}</span>
							<span v-else class="pkpPublication__statusUnpublished">{translate key="publication.status.unpublished"}</span>
						</span>
							<span v-if="publicationList.length > 1" class="pkpPublication__version">
								<strong tabindex="0">{{ versionLabel }}</strong> {{ workingPublication.version }}
								<dropdown
									class="pkpPublication__versions"
									label="{translate key="publication.version.all"}"
									:is-link="true"
									submenu-label="{translate key="common.submenu"}"
								>
									<ul>
										<li v-for="publication in publicationList" :key="publication.id">
											<button
												class="pkpDropdown__action"
												:disabled="publication.id === workingPublication.id"
												@click="setWorkingPublicationById(publication.id)"
											>
												{{ publication.version }} /
												<template v-if="publication.status === getConstant('STATUS_PUBLISHED')">{translate key="publication.status.published"}</template>
												<template v-else>{translate key="publication.status.unpublished"}</template>
											</button>
										</li>
									</ul>
								</dropdown>
							</span>
							<span class="pkpPublication__relation" v-if="workingPublication.status != getConstant('STATUS_PUBLISHED') || workingPublication.relationStatus != {$smarty.const.PUBLICATION_RELATION_PUBLISHED}"> 
								<dropdown
									class="pkpWorkflow__relation"
									label="{translate key="publication.relation"}"
								>
									<pkp-form class="pkpWorkflow__relateForm" v-bind="components.{$smarty.const.FORM_ID_RELATION}" @set="set">
								</dropdown>
							</span>
							{if $canPublish}
								<template slot="actions">
									<pkp-button
										v-if="workingPublication.status === getConstant('STATUS_QUEUED')"
										ref="publish"
										@click="openPublish"
									>
										{translate key="publication.publish"}
									</pkp-button>
									<pkp-button
										v-else-if="workingPublication.status === getConstant('STATUS_PUBLISHED')"
										:is-warnable="true"
										@click="openUnpublish"
									>
										{translate key="publication.unpublish"}
									</pkp-button>
								</template>
							{/if}
							<template slot="actions">
								<pkp-button
									v-if="workingPublication.relationStatus != {$smarty.const.PUBLICATION_RELATION_PUBLISHED} && canCreateNewVersion"
									ref="createVersion"
									@click="createVersion"
								>
									{translate key="publication.createVersion"}
								</pkp-button>
								<pkp-button
									v-if="workingPublication.status != getConstant('STATUS_PUBLISHED') && workingPublication.version > 1 && !workingPublication.versionJustification"
									ref="submitVersionButton"
									@click="$modal.show('submitVersion')"
								>
									{translate key="plugins.generic.authorVersion.publication.submitVersion"}
								</pkp-button>
								<modal
									v-bind="MODAL_PROPS"
									name="submitVersion"
									@closed="setFocusToRef('submitVersionButton')"
								>
									<modal-content
										id="submitVersionModal"
										modal-name="submitVersion"
										title="{translate key="plugins.generic.authorVersion.publication.submitVersion"}"
									>
										<pkp-form v-bind="components.submitVersionForm" @set="set" @success="location.reload()"></pkp-form>
									</modal-content>
								</modal>
							</template>
					</pkp-header>
					<div
						v-if="workingPublication.status === getConstant('STATUS_PUBLISHED')"
						class="pkpPublication__versionPublished"
					>
						{translate key="publication.editDisabled"}
					</div>
					<tabs :is-side-tabs="true" :track-history="true" class="pkpPublication__tabs" :label="publicationTabsLabel">
						<tab id="titleAbstract" label="{translate key="publication.titleAbstract"}">
							<pkp-form v-bind="components.{$smarty.const.FORM_TITLE_ABSTRACT}" @set="set" />
						</tab>
						<tab id="contributors" label="{translate key="publication.contributors"}">
							<div id="contributors-grid" ref="contributors">
								<spinner></spinner>
							</div>
						</tab>
						{if $metadataEnabled}
							<tab id="metadata" label="{translate key="submission.informationCenter.metadata"}">
								<pkp-form v-bind="components.{$smarty.const.FORM_METADATA}" @set="set" />
							</tab>
						{/if}
						<tab v-if="supportsReferences" id="citations" label="{translate key="submission.citations"}">
							<pkp-form v-bind="components.{$smarty.const.FORM_CITATIONS}" @set="set" />
						</tab>
						<tab id="galleys" label="{translate key="submission.layout.galleys"}">
							<div id="representations-grid" ref="representations">
								<spinner></spinner>
							</div>
						</tab>
						<tab id="queries" label="{translate key="submission.queries.production"}">
							<div id="queries-grid" ref="queries">
							{include file="controllers/tab/authorDashboard/production.tpl"}
							</div>
						</tab>
						{call_hook name="Template::Workflow::Publication"}
					</tabs>
					<span class="pkpPublication__mask" :class="publicationMaskClasses">
						<spinner></spinner>
					</span>
				</div>
			</tab>
			{call_hook name="Template::Workflow"}
		</tabs>
	</div>
{/block}


