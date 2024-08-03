//== Spinner
export const Spinner = <template>
  <img src="/images/spinner.svg" class="spinner" draggable="false" ondragstart="return false" {{action 'hideSpinner'}} style="display:none" title="V Ä N T A ! — eller stoppa med klick om det snurrar för länge">
</template>;
