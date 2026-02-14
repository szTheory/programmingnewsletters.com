const FILTER_CLASS = "filters__chip";
const FILTER_ACTIVE_CLASS = "filters__chip--active";
const ITEM_SELECTOR = ".feed__item";
const GROUP_SELECTOR = ".feed__group";
const HIDDEN_CLASS = "u-hidden";
const CATEGORY_ATTR = "data-category";
const CATEGORY_ALL = "All";

function filterCategory(filterElem) {
  if (filterElem.classList.contains(FILTER_ACTIVE_CLASS)) {
    return;
  }

  const filterElems = document.querySelectorAll(`.${FILTER_CLASS}`);
  filterElems.forEach((elem) => {
    elem.classList.remove(FILTER_ACTIVE_CLASS);
  });
  filterElem.classList.add(FILTER_ACTIVE_CLASS);

  const categoryName = filterElem.getAttribute(CATEGORY_ATTR);

  if (categoryName == CATEGORY_ALL) {
    showAllEntries();
    return;
  }

  const entries = document.querySelectorAll(ITEM_SELECTOR);
  entries.forEach((entry) => {
    const category = entry.getAttribute(CATEGORY_ATTR);
    if (category == categoryName) {
      entry.classList.remove(HIDDEN_CLASS);
    } else {
      entry.classList.add(HIDDEN_CLASS);
    }
  });

  const entryGroups = document.querySelectorAll(GROUP_SELECTOR);
  entryGroups.forEach((entryGroup) => {
    if (
      entryGroup.querySelectorAll(`${ITEM_SELECTOR}:not(.${HIDDEN_CLASS})`)
        .length == 0
    ) {
      entryGroup.classList.add(HIDDEN_CLASS);
    } else {
      entryGroup.classList.remove(HIDDEN_CLASS);
    }
  });
}

function showAllEntries() {
  const entries = document.querySelectorAll(ITEM_SELECTOR);
  entries.forEach((entry) => entry.classList.remove(HIDDEN_CLASS));

  const entryGroups = document.querySelectorAll(GROUP_SELECTOR);
  entryGroups.forEach((entryGroup) => {
    entryGroup.classList.remove(HIDDEN_CLASS);
  });
}

document.addEventListener("click", (event) => {
  if (event.target.classList.contains(FILTER_CLASS)) {
    filterCategory(event.target);
  }
});
