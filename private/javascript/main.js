const CATEGORY_FILTER_CLASS = "category-filter";
const CATEGORY_FILTER_ATTR = "data-category";
const ENTRIES_SELECTOR = ".entry";
const CATEGORY_NAME_ALL = "All";
const CATEGORY_FILTER_SELECTED_CLASS = "selected";
const HIDDEN_CLASS = "hidden";
const ENTRIES_CATEGORY_ATTR = "data-category";
const ENTRY_GROUPS_SELECTOR = ".entry-group";

function filterCategory(filterElem) {
  if (filterElem.classList.contains(CATEGORY_FILTER_SELECTED_CLASS)) {
    // already selected so don't bother
    return;
  }

  const filterElems = document.querySelectorAll(`.${CATEGORY_FILTER_CLASS}`);
  filterElems.forEach((filterElem) => {
    filterElem.classList.remove(CATEGORY_FILTER_SELECTED_CLASS);
  });
  filterElem.classList.add(CATEGORY_FILTER_SELECTED_CLASS);

  const categoryName = event.target.getAttribute(CATEGORY_FILTER_ATTR);

  if (categoryName == CATEGORY_NAME_ALL) {
    showAllEntries();
    return;
  }

  const entries = document.querySelectorAll(ENTRIES_SELECTOR);
  entries.forEach((entry) => {
    const category = entry.getAttribute(ENTRIES_CATEGORY_ATTR);
    if (category == categoryName) {
      entry.classList.remove(HIDDEN_CLASS);
    } else {
      entry.classList.add(HIDDEN_CLASS);
    }
  });

  const entryGroups = document.querySelectorAll(ENTRY_GROUPS_SELECTOR);
  entryGroups.forEach((entryGroup) => {
    if (
      entryGroup.querySelectorAll(`${ENTRIES_SELECTOR}:not(.${HIDDEN_CLASS})`)
        .length == 0
    ) {
      entryGroup.classList.add(HIDDEN_CLASS);
    } else {
      entryGroup.classList.remove(HIDDEN_CLASS);
    }
  });
}

function showAllEntries() {
  const entries = document.querySelectorAll(ENTRIES_SELECTOR);
  entries.forEach((entry) => entry.classList.remove(HIDDEN_CLASS));

  const entryGroups = document.querySelectorAll(ENTRY_GROUPS_SELECTOR);
  entryGroups.forEach((entryGroup) => {
    entryGroup.classList.remove(HIDDEN_CLASS);
  });
}

document.addEventListener("click", (event) => {
  if (event.target.classList.contains(CATEGORY_FILTER_CLASS)) {
    const filterElem = event.target;
    filterCategory(filterElem);
  }
});
