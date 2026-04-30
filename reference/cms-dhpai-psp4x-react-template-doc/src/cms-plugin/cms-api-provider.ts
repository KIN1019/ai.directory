import { ApiContext } from "@cmschassis/cms-js";

// a global variable for get & set ApiContext
let apiContext: ApiContext;

/**
 * A class to get & set ApiContext. To let api consumer to access with native getter
 * - e.g. api.command.xxx
 */
class CmsInstance {
	get api() {
		return apiContext;
	}

	set api(context: ApiContext) {
		apiContext = context;
	}
}

const inst = new CmsInstance();

// export the getting interface
export default inst;
